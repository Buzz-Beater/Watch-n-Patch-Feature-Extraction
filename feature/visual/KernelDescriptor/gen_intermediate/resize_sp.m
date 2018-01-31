
% written by Liefeng Bo on 03/27/2012 in University of Washington
% modified by Baoxiong Jia in UCLA, 2018
config;


for idx = 1 : length(params.im_rt_dir)  
    im_dirs = dir_bo(fullfile(params.rt_dir, 'features', 'superpixel', 'rgb_origin', params.im_rt_dir{idx}));
    im_dirs = sort({im_dirs.name});
    parfor dir_idx = 1 : length(im_dirs)
        tic;
        data_path = fullfile(params.rt_dir,'features', 'superpixel', 'rgb_origin', params.im_rt_dir{idx}, im_dirs{dir_idx});
        foreground_path = fullfile(params.rt_dir, 'features', 'foreground', params.im_rt_dir{idx}, im_dirs{dir_idx});
        imsubdir = dir_bo(data_path);
        savedir = fullfile(params.rt_dir,'features', 'superpixel', 'rgb', params.im_rt_dir{idx}, im_dirs{dir_idx});
        mkdir_bo(savedir);
        for img_idx = 1 : length(imsubdir)
        	U = load(fullfile(data_path, imsubdir(img_idx).name));
        	U = imresize(U.U, 0.5);
            seg = int16(bwlabel(U <= 0.08));
        	save_seg(fullfile(savedir, num2str(img_idx, '%04d')), seg);
        end
        toc
    end
end