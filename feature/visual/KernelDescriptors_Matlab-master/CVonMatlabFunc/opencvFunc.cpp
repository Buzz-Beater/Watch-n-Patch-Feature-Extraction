#include <opencv2/opencv.hpp>
#include <iostream>
#include "mex.h"

#define HAS_OPENCV
#include "mc_convert/mc_convert.h"
#include "mc_convert/mc_convert.cpp"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    //plhs outputs
    //prhs inputs

    //How to use
    //Image=imread('lena.jpg');
    //output=matlabCV(Image);
    
    IplImage* inputImg = mxArr_to_new_IplImage(prhs[0]);
    std::cout << inputImg->depth << std::endl;
    const int *size = mxGetDimensions(prhs[0]);
    //int channels = mxGetNumberOfDimensions(prhs[0]);
    //std::cout << size[0] << " " << channels << std::endl;
    /*
    IplImage* inputImg = cvCreateImage( cvSize( size[1], size[0] ), IPL_DEPTH_32F, 1 );
    double* matlabImage;
    matlabImage = (double*)mxGetData(prhs[0]);
    
    for( int i = 0; i < inputImg->height; i++ ){
        for( int j = 0; j < inputImg->width; j++ ){
            
            if( inputImg->nChannels == 3 ){
                //Normal --> RGB
                //OpenCV --> BGR
                inputImg->imageData[i*inputImg->widthStep+j*inputImg->nChannels+0]
                = matlabImage[(i+j*inputImg->height)+(inputImg->width*inputImg->height*2)];
                
                inputImg->imageData[i*inputImg->widthStep+j*inputImg->nChannels+1]
                = matlabImage[(i+j*inputImg->height)+(inputImg->width*inputImg->height*1)];
                
                inputImg->imageData[i*inputImg->widthStep+j*inputImg->nChannels+2]
                = matlabImage[(i+j*inputImg->height)+(inputImg->width*inputImg->height*0)];
            }else{
                for( int k = 0; k < inputImg->nChannels; k++ ){
                    inputImg->imageData[i*inputImg->widthStep+j*inputImg->nChannels+k]
                    = matlabImage[(i+j*inputImg->height)+(inputImg->width*inputImg->height*k)];
                }
            }
            
        }
    }
    */
    
    
    
    //IplImage* filterX = mxArr_to_new_IplImage(prhs[1]);
    //IplImage* filterY = mxArr_to_new_IplImage(prhs[2]);
    //std::cout << filterX->depth << " " << filterX->nChannels << std::endl;
    //std::cout << (int)filterX->imageData[ 100 ] << std::endl;
    
    //CvMat *G_X = cvCreateMat( 5, 5, CV_32FC1 );
    //CvMat *G_Y = cvCreateMat( 5, 5, CV_32FC1 );
    //G_X = mxArr_to_new_CvMat( prhs[1] );
    //G_Y = mxArr_to_new_CvMat( prhs[2] );
    CvMat *G_X = cvCreateMat( 5, 5, CV_32FC1 );
    CvMat *G_Y = cvCreateMat( 5, 5, CV_32FC1 );
    //CvMat *tmpX = mxArr_to_new_CvMat( prhs[1] );
    //CvMat *tmpY = mxArr_to_new_CvMat( prhs[2] );
    
    
    double* ptrX = (double*)mxGetData(prhs[1]);
    double* ptrY = (double*)mxGetData(prhs[2]);
    //const int* size = mxGetDimensions(prhs[1]);
    //std::cout << size[1] << std::endl;
    for( int i = 0; i < G_X->height; i++ ){
        for( int j= 0; j < G_X->width; j++ ){
            //std::cout << (double)tmpX->data.ptr[ i * 5 +j] << std::endl;
            //std::cout << ptr[i*5+j]<< std::endl;
            //std::cout << ptrX[i+j*G_X->height] << std::endl;
            
            /*
            G_X->data.ptr[i*G_X->width+j] = 
            ptrY[i+j*G_X->height];
            G_Y->data.ptr[i*G_Y->width+j] = 
            ptrY[i+j*G_Y->height];
            */
            
            cvmSet( G_X, i, j, ptrX[i+j*G_X->height] );
            cvmSet( G_Y, i, j, ptrY[i+j*G_Y->height] );
            //std::cout << cvmGet( G_X, i, j ) << " ";
        }
    }
    
    //std::cout << G_X->width << std::endl;
    //std::cout << G_Y->type << std::endl;
    
    /*
    CvMat dAx_cvfilter = cvMat( filterX->height,
                                filterX->width,
                                CV_32FC1, filterX->imageData );
    //cvConvert( filterX, &dAx_cvfilter );
    CvMat dAy_cvfilter = cvMat( filterY->height,
                               filterY->width,
                               CV_32FC1, filterY->imageData );
    //cvConvert( filterY, &dAy_cvfilter );
    */
    
    IplImage* imX = cvCreateImage( cvSize( inputImg->width, inputImg->height ),
                                  IPL_DEPTH_64F, 1 );
    IplImage* imY = cvCreateImage( cvSize( inputImg->width, inputImg->height ),
                                  IPL_DEPTH_64F, 1 );
    
    cvFilter2D( inputImg, imX, G_X );
    cvFilter2D( inputImg, imY, G_Y );
    
    //cvSaveImage( "imX.jpg", imX, 0 );
    //cvSaveImage( "fil.jpg", filter, 0 );
    plhs[0] = IplImage_to_new_mxArr(imX);
    plhs[1] = IplImage_to_new_mxArr(imY);
    //plhs[2] = IplImage_to_new_mxArr(filterX);
    //plhs[3] = IplImage_to_new_mxArr(filterY);
    
  return;
}
