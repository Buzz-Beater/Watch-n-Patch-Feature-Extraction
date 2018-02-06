
% written by Liefeng Bo on 03/27/2012 in University of Washington
% modified by Baoxiong Jia in UCLA, 2018

function [] = gen_kdes_subsample(kdes_type)

    config;
    
    if contains(kdes_type, 'dep') || contains(kdes_type, 'normal') || contains(kdes_type, 'spin')
        params.type = 'depth';
    else
        params.type = 'rgbjpg';
    end

    for idx = 1 : length(params.im_rt_dir)  
        im_dirs = dir_bo(fullfile(params.rt_dir, params.im_rt_dir{idx}));
        im_dirs = sort({im_dirs.name});
        for dir_idx = 1 : params.dir_skip : length(im_dirs)
            data_path = fullfile(params.rt_dir, params.im_rt_dir{idx}, im_dirs{dir_idx});
            imsubdir = dir_bo(fullfile(data_path, params.type));
            impath = cell(1, length(1 : params.file_skip : length(imsubdir)));
            file_idx = 1;
            for img_idx = 1 : params.file_skip : length(imsubdir)
                impath{file_idx} = fullfile(data_path, params.type, imsubdir(img_idx).name);
                file_idx = file_idx +  1;
            end
            savedir = fullfile(params.rt_dir, 'kdes', kdes_type, params.im_class{double(idx > 1) + 1});

            % initialize the parameters of kdes
            kdes_params.grid = params.grid;   % kdes is extracted every 8 pixels
            kdes_params.patchsize = params.patchsize;  % patch size
            load([kdes_type '_params']);
            eval(['kdes_params.kdes = ' kdes_type '_params;']);

            % initialize the parameters of data
            data_params.datapath = impath;
            data_params.tag = 1;
            data_params.minsize = 45;  % minimum size of image
            data_params.maxsize = params.maxsize; % maximum size of image
            data_params.savedir = savedir;
            data_params.prefix = im_dirs{dir_idx};

            % extract kernel descriptors
            mkdir_bo(data_params.savedir);
            gen_kdes_batch(data_params, kdes_params);
        end
    end
    %rmdir('/home/baoxiong/Projects/WNP-Preprocess/Dataset/kdes/grad_depth', 's');
end
