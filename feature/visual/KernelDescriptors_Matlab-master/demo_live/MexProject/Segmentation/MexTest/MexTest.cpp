// MexTest.cpp : DLL アプリケーション用にエクスポートされる関数を定義します。
/* 2012/10/25 Written by Hideshi T. @DHRC 
 *
 * This is Point Cloud Library Program
 * in order to segmentation objects on tables.
 * e.x. downsampling, plane fitting and clustering
 * And this is mex-file. So, called from matlab.
 *
 */

#define DEBUG 1
#define Z_LIMIT 0.8
#define PLANE_THRESHOLD 0.02
#define CLUSTER_THRESHOLD 0.02
#define MIN_POINTS_LIMIT 200
#define MAX_POINTS_LIMIT 2000

#include <iostream>
#include <pcl/io/io.h>
#include <pcl/visualization/cloud_viewer.h>
#include <pcl/io/pcd_io.h>
#include <iostream>
#include <pcl/io/io.h>
#include <vector>
#include <boost/timer.hpp>
#include <pcl/ModelCoefficients.h>  
#include <pcl/point_types.h>  
#include <pcl/kdtree/kdtree.h>
#include <pcl/sample_consensus/method_types.h>  
#include <pcl/sample_consensus/model_types.h>  
#include <pcl/segmentation/sac_segmentation.h>  
#include <pcl/segmentation/extract_clusters.h>
#include <pcl/visualization/cloud_viewer.h>  
#include <pcl/filters/extract_indices.h>
#include <pcl/filters/voxel_grid.h>
#include <pcl/filters/passthrough.h>
#include <pcl/features/normal_3d.h>
#include <pcl/range_image/range_image.h>
#include <pcl/range_image/range_image_planar.h>

//PCLより前にincludeしてはだめ max() がかちあう
#include "mex.h"
#include "matrix.h"
#include "stdafx.h"

std::vector<Eigen::Vector4f> pt3d;
std::vector<Eigen::Vector2f> pt2d;


////////////////////////////////////////////////////////
// create bundingbox with point cloud
////////////////////////////////////////////////////////
void bundingbox( std::vector< pcl::PointCloud<pcl::PointXYZRGBA> >& clusteredsubdivide )
{
	Eigen::Vector4f min_point;
	Eigen::Vector4f max_point;
	
	pt3d.clear();
	for( int i = 0; i < clusteredsubdivide.size(); i++ ){
		
		pcl::getMinMax3D( clusteredsubdivide[i], min_point, max_point );

		pt3d.push_back( min_point );
		pt3d.push_back( max_point );
      
	}
}


////////////////////////////////////////////////////////
// mex-file interface
////////////////////////////////////////////////////////
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
#if DEBUG
	mexPrintf("Mex-Function\n");
#endif
	/*
	 * nlhs The number of outputs
	 * plhs output mxArray's ptr
	 * nrhs The number of inputs
	 * prhs input mxArray`s ptr
	 */

   
	/*
	* Prepare Dataset
	*/
	int height = mxGetM( prhs[0] );
	int width = mxGetN( prhs[0] );
	int dim = 3;//nrhs;
#if DEBUG
	mexPrintf("height, width, dim %d %d %d\n", height, width, nrhs );
#endif	
	double *ptr[3];
	for( int i = 0; i < nrhs; i++ ){
		ptr[i] = mxGetPr(prhs[i]);
		//plhs[i] = mxCreateDoubleMatrix(height, width, mxREAL);//for return
	}
	
	pcl::PointCloud<pcl::PointXYZRGBA> cloud;
	pcl::PointCloud<pcl::PointXYZRGBA> clustered;
	std::vector< pcl::PointCloud<pcl::PointXYZRGBA> > clusteredsubdivide;

	//How to access 
	for( int w = 0; w < width; w++ ){
		for( int h = 0; h < height; h++ ){
			//MatlabとCの配列の格納順が違う
			//Matlabは縦方向からだが、Cは横方向
			//よって、Cでは横方向に高さデータが格納されている
			//mexPrintf("%lf ", *(ptr[0]+h+height*w));

			pcl::PointXYZRGBA tmp;
			tmp.x = *(ptr[0]+h+height*w) / 1000.0;//mm -> m
			tmp.y = *(ptr[1]+h+height*w) / 1000.0;
			tmp.z = *(ptr[2]+h+height*w) / 1000.0;

			cloud.push_back( tmp );
			//mexPrintf("%lf ", cloud.points[h+height*w].x);
			//mexPrintf("%lf ", ptr[3]);
		}
		//mexPrintf("\n");
	}
	cloud.height = height;
	cloud.width = width;
	cloud.points.resize( width * height );



	/*
	 * Point Cloud Library Function
     * Plane Fitting	 
	 */

	boost::timer t;

	pcl::ModelCoefficients::Ptr coefficients (new pcl::ModelCoefficients);  
	pcl::PointIndices::Ptr inliers (new pcl::PointIndices);  
 
	//delete nan data nad not near data from kinect raw data
	pcl::PassThrough<pcl::PointXYZRGBA> pass;
	pass.setInputCloud( cloud.makeShared() );//makeShared provide smartPtr.
	pass.setFilterFieldName( "z" );
	pass.setFilterLimits( 0.0, Z_LIMIT );//m
	pass.filter( cloud );

	pcl::VoxelGrid<pcl::PointXYZRGBA> sor;
	sor.setInputCloud( cloud.makeShared() );
	sor.setLeafSize( 0.005f, 0.005f, 0.002f );//5mm, 5mm, 2mm
	sor.filter( cloud );
  
	//std::cout << "Down Sampling:" << t.elapsed() << " sec" << std::endl;
	mexPrintf( "Down Sampling:%lf sec\n", t.elapsed() );
	t.restart();

	// Create the segmentation object  
	pcl::SACSegmentation<pcl::PointXYZRGBA> seg;  
	// Optional  
	seg.setOptimizeCoefficients (true);  
	// Mandatory  
	seg.setModelType (pcl::SACMODEL_PLANE);  
	seg.setMethodType (pcl::SAC_RANSAC);  
	seg.setDistanceThreshold (PLANE_THRESHOLD);//2cm
  
	seg.setInputCloud (cloud.makeShared ());  
	seg.segment (*inliers, *coefficients);

	// Extract the rest part
	pcl::ExtractIndices<pcl::PointXYZRGBA> extract;
  
	//pcl::PointCloud<pcl::PointXYZRGBA> filter;
	pcl::PointCloud<pcl::PointXYZRGBA>::Ptr
		cloud_filtered(new pcl::PointCloud<pcl::PointXYZRGBA>);
	
	extract.setInputCloud( cloud.makeShared() );
	extract.setIndices( inliers );
	//true:delete plane part, false:delete not plane part.
	extract.setNegative( true );
	//extract.filter( cloud );
	extract.filter( *cloud_filtered );
	
	//std::cout << "Plane Segmentation:" << t.elapsed() << " sec" << std::endl;
	mexPrintf( "Plane Segmentation:%lf sec\n", t.elapsed() );
	t.restart();
	

	/*
	 * Point Cloud Library Function
     * Clustering
	 */	
	pcl::search::KdTree<pcl::PointXYZRGBA>::Ptr
		tree(new pcl::search::KdTree<pcl::PointXYZRGBA>);
	tree->setInputCloud( cloud_filtered );
	
	std::vector<pcl::PointIndices> cluster_indices;
	pcl::EuclideanClusterExtraction<pcl::PointXYZRGBA> ec;
	ec.setClusterTolerance( CLUSTER_THRESHOLD );//2cm
	ec.setMinClusterSize( MIN_POINTS_LIMIT );
	ec.setMaxClusterSize( MAX_POINTS_LIMIT );
	ec.setSearchMethod( tree );
	ec.setInputCloud( cloud_filtered );
	ec.extract( cluster_indices );
	
	for( std::vector<pcl::PointIndices>::const_iterator it = cluster_indices.begin();
		it != cluster_indices.end();
		++it )
	{
		pcl::PointCloud<pcl::PointXYZRGBA> cloud_cluster;
	
		for( std::vector<int>::const_iterator pit = it->indices.begin();
			pit != it->indices.end();
			pit++ )
		{
			cloud_cluster.points.push_back( cloud_filtered->points[*pit] );
		}
		
		//Store Native Data per segmentation object
		cloud_cluster.width = cloud_cluster.points.size();
		cloud_cluster.height = 1;
		cloud_cluster.is_dense = true;
		
		clusteredsubdivide.push_back( cloud_cluster );
		//std::cout << cloud_cluster.points.size() << std::endl;
#if DEBUG
		mexPrintf("The number of points : %d\n", cloud_cluster.points.size() );
#endif
		//Store Coloring Data for all segmentation object
		clustered.width = clustered.points.size();
		clustered.height = 1;
		clustered.is_dense = true;
		
		//Save
		//std::stringstream ss;
		//ss << "cloud_cluster_" << j << ".pcd";
		//writer.write<pcl::PointXYZRGBA>( ss.str(), *cloud_cluster, false );
	}
	
	//std::cout << "Clustering:" << t.elapsed() << " sec" << std::endl << std::endl;
	mexPrintf("Cloustering:%lf sec\n", t.elapsed());
	mexPrintf("Object num is %d\n", clusteredsubdivide.size());

	
	/*
	 * Point Cloud Library Function
     * Bundingbox
	 */	
	bundingbox( clusteredsubdivide );

	
	/*
     * Output
	 */
	plhs[0] = mxCreateDoubleMatrix( dim, pt3d.size(), mxREAL );
	double* ptr_out = mxGetPr(plhs[0]);
	for( int i = 0; i < pt3d.size(); i++ ){
		ptr_out[i*dim + 0] = pt3d[i].x();
		ptr_out[i*dim + 1] = pt3d[i].y();
		ptr_out[i*dim + 2] = pt3d[i].z();
#if DEBUG
		mexPrintf("%lf %lf %lf\n", pt3d[i].x(), pt3d[i].y(), pt3d[i].z() );
#endif
		//縦方向にx, y, z 横方向が点
	}
}