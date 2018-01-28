% add paths
addpath('../helpfun');
addpath('../kdes');
addpath('../emk');

% compute the paths of images
params.rt_dir = '/home/baoxiong/Projects/WNP-Preprocess/Dataset';
params.im_rt_dir = {'office', 'kitchen1', 'kitchen2'};
params.img_class = {'office', 'kitchen'};

params.kparam = {0.001, 0.001, 0.01, 0.01, 0.1, 0.1};
params.kname = {'gradkdes_dep', 'gradkdes', 'lbpkdes', 'nrgbkdes_params', 'normalkdes', 'spinkdes'};

params.word_type = 400;
params.max_size = 960;
params.threshold = 0.05;
params.grid = 8;
params.patchsize = 16;