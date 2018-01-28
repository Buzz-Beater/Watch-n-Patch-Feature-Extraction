% add paths
addpath('../helpfun');
addpath('../kdes');
addpath('../emk');

% compute the paths of images
rt_dir = '/home/baoxiong/Projects/WNP-Preprocess/Dataset';
im_rt_dir = {'office', 'kitchen1', 'kitchen2'};
im_class = {'office', 'kitchen'};

params.samplenum = 1000;
params.num_iter = 10;
params.wordnum = 400;
