//#include <cv.h>
//#include <highgui.h>
//#include <ctype.h>

#include <opencv2/opencv.hpp>
#include <iostream>
#include "mex.h"

#define HAS_OPENCV
#include "mc_convert/mc_convert.h"
#include "mc_convert/mc_convert.cpp"

int capture()
{
  CvCapture *capture = 0;
  IplImage *frame = 0;
  double w = 320, h = 240;
  int c;
  
  capture = cvCreateCameraCapture (0);
  
  cvSetCaptureProperty (capture, CV_CAP_PROP_FRAME_WIDTH, w);
  cvSetCaptureProperty (capture, CV_CAP_PROP_FRAME_HEIGHT, h);
  
  //cvNamedWindow ("Capture", CV_WINDOW_AUTOSIZE);
  
  while (1) {
    frame = cvQueryFrame (capture);
      std::cout << frame->width << " " << frame->height << std::endl;
    //cvShowImage ("Capture", frame);
      cvSaveImage( "matlab.jpg", frame, 0 );
      break;
      /*
    c = cvWaitKey (2) & 0xff;
    if (c == '\x1b')
      break;
       */
  }
  
  cvReleaseCapture (&capture);
  //cvDestroyWindow ("Capture");
  
  return 0;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    //plhs outputs
    //prhs inputs
    
    //Sample1:This is Live Camera Program
    //capture();
    //return;
    
    
    //Sample2:
    //How to use
    //Image=imread('lena.jpg');
    //matlabCV(Image);
    
    //Input Image
    /*
    const int *size;
    size = mxGetDimensions(prhs[0]);
    int channels = mxGetNumberOfDimensions(prhs[0]);
    //std::cout << channels << std::endl;
    IplImage* image = cvCreateImage( cvSize( size[1], size[0] ), IPL_DEPTH_8U, channels );
    unsigned char* matlabImage;
    matlabImage = (unsigned char*)mxGetData(prhs[0]);
    
    for( int i = 0; i < image->height; i++ ){
        for( int j = 0; j < image->width; j++ ){
            
            if( image->nChannels == 3 ){
                //Normal --> RGB
                //OpenCV --> BGR
                image->imageData[i*image->widthStep+j*image->nChannels+0]
                = matlabImage[(i+j*image->height)+(image->width*image->height*2)];
                
                image->imageData[i*image->widthStep+j*image->nChannels+1]
                = matlabImage[(i+j*image->height)+(image->width*image->height*1)];
                
                image->imageData[i*image->widthStep+j*image->nChannels+2]
                = matlabImage[(i+j*image->height)+(image->width*image->height*0)];
            }else{
                for( int k = 0; k < image->nChannels; k++ ){
                    image->imageData[i*image->widthStep+j*image->nChannels+k]
                    = matlabImage[(i+j*image->height)+(image->width*image->height*k)];
                }
            }
            
        }
    }
     */
    IplImage* image = mxArr_to_new_IplImage(prhs[0]);
    cvSaveImage( "test.jpg", image, 0 );
    plhs[0] = IplImage_to_new_mxArr(image); 
    
  return;
}
