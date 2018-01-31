% written by Liefeng Bo on 03/27/2012 in University of Washington
% modified by Baoxiong Jia on 01/11/2018 in UCLA

function [] = gen_visual_words(kdes_type)
    
    run config;
    for idx = 1 : length(im_class)

        scene_type = im_class{idx};
        
        basis_params.samplenum = params.samplenum; % maximum sample number per image scale
        basis_params.wordnum = params.wordnum; % number of visual words
        basis_params.num_iter = params.num_iter;
    
        kdes_path = get_kdes_path(fullfile(rt_dir, 'kdes', kdes_type, scene_type));
        
        fea_params.feapath = kdes_path;
        fea_params.scene_type = scene_type;
        rgbdwords = visualwords(fea_params, basis_params);
    
        save_dir = ['../seg_kernel/visual_words/' kdes_type '_' scene_type '_' num2str(basis_params.samplenum) '.mat'];
        save(save_dir, 'rgbdwords');
    end
end
%rmdir('/home/baoxiong/Projects/WNP-Preprocess/Dataset/kdes/grad_depth', 's');
