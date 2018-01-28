
% written by Liefeng Bo on 03/27/2012 in University of Washington
% modified by Baoxiong Jia on 01/11/2018 in UCLA

clear;

% add paths
addpath('../../helpfun');
addpath('../../kdes');
addpath('../../emk');

% compute the paths of images
rt_dir = '/home/baoxiongjia/Projects/WNP-Preprocess/Dataset';
im_rt_dir = {'office', 'kitchen1', 'kitchen2'};
class_category = {'office', 'kitchen'};
for idx = 1 : 2  
    im_dirs = dir_bo(fullfile(rt_dir, im_rt_dir{idx}));
    im_dirs = sort({im_dirs.name});
    for dir_idx = 1 :  length(im_dirs)
        data_path = fullfile(rt_dir, im_rt_dir{idx}, im_dirs{dir_idx});
        imsubdir = dir_bo(fullfile(data_path, 'depth'));
        impath = cell(1, length(imsubdir));
        for img_idx = 1 : length(imsubdir)
            impath{img_idx} = fullfile(data_path, 'depth', imsubdir(img_idx).name);  
        end
        
        savedir = fullfile(rt_dir, 'kdes', 'grad_depth', im_rt_dir{idx});

        % initialize the parameters of kdes
        kdes_params.grid = 8;   % kdes is extracted every 8 pixels
        kdes_params.patchsize = 16;  % patch size
        load('gradkdes_dep_params');
        kdes_params.kdes = gradkdes_dep_params;

        % initialize the parameters of data
        data_params.datapath = impath;
        data_params.tag = 1;
        data_params.minsize = 45;  % minimum size of image
        data_params.maxsize = 960; % maximum size of image
        data_params.savedir = savedir;
        data_params.prefix = im_dirs{dir_idx};

        % extract kernel descriptors
        mkdir_bo(data_params.savedir);
        rgbdkdespath = get_kdes_path(data_params.savedir);
        
            gen_kdes_batch(data_params, kdes_params);
            rgbdkdespath = get_kdes_path(data_params.savedir);
    end
end


