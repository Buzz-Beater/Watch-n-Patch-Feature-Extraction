% written by Liefeng Bo on 03/27/2012 in University of Washington
% modified by Baoxiong Jia on 01/11/2018 in UCLA

clear;

% add paths
addpath('../../helpfun');
addpath('../../kdes');
addpath('../../emk')
run config;
% compute the paths of images
rt_dir = '/home/baoxiongjia/Projects/WNP-Preprocess/Dataset';
im_rt_dir = {'office', 'kitchen1', 'kitchen2'};
im_class = {'office', 'kitchen'};
kdes_path = cell(1, 2);
for idx = 1 : 3  
    im_dirs = dir_bo(fullfile(rt_dir, im_rt_dir{idx}));
    im_dirs = sort({im_dirs.name});
    for dir_idx = 1 : params.dir_skip : length(im_dirs)
        data_path = fullfile(rt_dir, im_rt_dir{idx}, im_dirs{dir_idx});
        imsubdir = dir_bo(fullfile(data_path, 'depth'));
        impath = cell(1, length(1 : params.file_skip : length(imsubdir)));
        file_idx = 1;
        for img_idx = 1 : params.file_skip : length(imsubdir)
            impath{file_idx} = fullfile(data_path, 'depth', imsubdir(img_idx).name);
            file_idx = file_idx +  1;
        end
        savedir = fullfile(rt_dir, 'kdes', 'spin_depth', im_class{double(idx > 1) + 1});

        % initialize the parameters of kdes
        kdes_params.grid = 8;   % kdes is extracted every 8 pixels
        kdes_params.patchsize = 16;  % patch size
        load('spinkdes_params');
        kdes_params.kdes = spinkdes_params;

        % initialize the parameters of data
        data_params.datapath = impath;
        data_params.tag = 1;
        data_params.minsize = 45;  % minimum size of image
        data_params.maxsize = 960; % maximum size of image
        data_params.savedir = savedir;
        data_params.prefix = im_dirs{dir_idx};

        % extract kernel descriptors
        mkdir_bo(data_params.savedir);
        gen_kdes_batch(data_params, kdes_params);
        rgbdkdespath = get_kdes_path(data_params.savedir);
    end
    if idx ~= 2
        kdes_path{double(idx > 1) + 1} = get_kdes_path(data_params.savedir);
    end
end


for idx = 1 : length(kdes_path)
    % learn visual words using K-means
    % initialize the parameters of basis vectors
    basis_params.samplenum = params.samplenum; % maximum sample number per image scale
    basis_params.wordnum = 1000; % number of visual words
    basis_params.num_iter = params.num_iter;
    fea_params.feapath = kdes_path{idx};
    rgbdwords = visualwords(fea_params, basis_params);
    basis_params.basis = rgbdwords;
    
    
    %{
    % constrained kernel SVD coding
    disp('Extract image features ... ...');
    % initialize the params of emk
    emk_params.pyramid = [1 2 3];
    emk_params.ktype = 'rbf';
    emk_params.kparam = 0.001;
    fea_params.feapath = kdes_path{i};
    rgbdfea = cksvd_emk_batch(fea_params, basis_params, emk_params);
    rgbdfea = single(rgbdfea);
    %}
    save -v7.3 rgbdfea_depth_spinkdes rgbdwords;
end
%rmdir('/home/baoxiong/Projects/WNP-Preprocess/Dataset/kdes/spin_depth', 's');
