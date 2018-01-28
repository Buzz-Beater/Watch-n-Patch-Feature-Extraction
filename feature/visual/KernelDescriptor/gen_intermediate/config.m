% add paths
addpath('../helpfun');
addpath('../kdes');
addpath('../emk')

% compute the paths of images
params.rt_dir = '/home/baoxiong/Projects/WNP-Preprocess/Dataset';
params.im_rt_dir = {'office', 'kitchen1', 'kitchen2'};
params.im_class = {'office', 'kitchen'};

params.dir_skip = 100;
params.file_skip = 100;
params.grid = 8;
params.patchsize = 16;
params.maxsize = 960;