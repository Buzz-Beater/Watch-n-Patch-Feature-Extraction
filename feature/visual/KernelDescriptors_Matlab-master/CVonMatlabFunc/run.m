load('G_X.mat');
load('G_Y.mat');
img = imread( 'koaramarch_1_10_crop.png', 'png' );
gray = rgb2gray(img);
gray=im2double(gray);
[imX, imY]=opencvFunc( gray, G_X, G_Y );