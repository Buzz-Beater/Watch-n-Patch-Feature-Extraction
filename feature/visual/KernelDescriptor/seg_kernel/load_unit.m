function [I, seg] = load_unit(rt_dir, rel_dir, img_idx, params)
    sp_path = fullfile(rt_dir, 'features', 'superpixel', params.type, rel_dir, [num2str(img_idx, '%04d') '.mat']);
    switch params.type
        case 'rgbjpg'
            img_path = fullfile(rt_dir, rel_dir, params.type, [num2str(img_idx, '%04d') '.jpg']);
            I = imread(img_path);
            if max(size(I)) > params.max_size
                I = imresize(I, params.max_size / max(size(I)), 'bicubic');
            end
            file = load(sp_path);
            seg = file.seg;
        otherwise
            img_path = fullfile(rt_dir, rel_dir, params.type, [num2str(img_idx, '%04d') '.mat']);
            I = load(img_path);
            I = I.depth;
            ucm = load(sp_path);
            U = ucm.U;
            if max(size(U)) > params.max_size
                U = imresize(U, params.max_size / max(size(U)), 'bicubic');
            end
            seg = bwlabel(U <= params.dep_threshold);
    end
end