% add paths
addpath('../helpfun');
addpath('../kdes');
addpath('../emk')

% compute the paths of images
params.rt_dir = '/home/baoxiongjia/Projects/WNP-Preprocess/Dataset';
params.im_rt_dir = {'office'};
params.im_class = {'office', 'kitchen'};

params.dir_skip = 4;
params.file_skip = 5;
params.grid = 8;
params.patchsize = 40;
params.maxsize = 960;
