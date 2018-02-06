
% mainly written by Liefeng Bo on 03/27/2012 in University of Washington
% modified by Baoxiong Jia on 01/11/2018 in UCLA

function [] = extract_kpca_fea(kdes_type)

    run config.m;
    
    if contains(kdes_type, 'dep') || contains(kdes_type, 'normal') || contains(kdes_type, 'spin')
        params.type = 'depth';
    else
        params.type = 'rgbjpg';
    end
    
    k_index = find(strcmp(params.kname, kdes_type));
    kparam = params.kparam{k_index};
    
    for idx = 1 : length(params.im_rt_dir)
        % load params and kdes words
        meta_words = load_kdes_words(kdes_type, kparam, params.img_class{double(idx > 1) + 1}, params.word_type);

        im_dirs = dir_bo(fullfile(params.rt_dir, params.im_rt_dir{idx}));
        im_dirs = sort({im_dirs.name});
        for dir_idx = 1 :  length(im_dirs)
            tic;
            data_path = fullfile(params.rt_dir, params.im_rt_dir{idx}, im_dirs{dir_idx});
            imsubdir = dir_bo(fullfile(data_path, params.type));
            rel_dir = fullfile(params.im_rt_dir{idx}, im_dirs{dir_idx});
            savedir = fullfile(params.rt_dir, 'kdes', kdes_type, rel_dir);

            % initialize the parameters of kdes
            kdes_params.grid = params.grid;   % kdes is extracted every 8 pixels
            kdes_params.patchsize = params.patchsize;  % patch size
            if contains(kdes_type, 'normal') || contains(kdes_type, 'spin')
                kdes_params.patchsize = 40;
            end
            kdes_params.kdes = meta_words.params;

            % extract kernel descriptors
            mkdir_bo(savedir);
            parfor img_idx = 1 : length(imsubdir)
                tic;
                [I, seg] = load_unit(params.rt_dir, rel_dir, img_idx, params);
                feaSet = gen_fea(I, kdes_params, kdes_type);
                feaSet.feaArr{1} = single(feaSet.feaArr{1});
                kdes = cksvd_emk_seg(feaSet, meta_words.words, meta_words.G, seg, meta_words.ktype, meta_words.kparam);
                save_dir = fullfile(savedir, [num2str(img_idx, '%04d') '.mat']);
                save_feature(save_dir, kdes);
                toc;
            end
            toc
        end
    end
end


