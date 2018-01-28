function [] = extractSuperpixel(file_path, save_path)
    model=load('models/forest/modelBsds'); model=model.model;
    model.opts.nms=-1; model.opts.nThreads=4;
    model.opts.multiscale=0; model.opts.sharpen=2;
    % opts for spDetect (see spDetect.m)
    opts = spDetect;
    opts.nThreads = 4;  % number of computation threads
    opts.k = 512;       % controls scale of superpixels (big k -> big sp)
    opts.alpha = .5;    % relative importance of regularity versus data terms
    opts.beta = .9;     % relative importance of edge versus color terms
    opts.merge = 0;     % set to small value to merge nearby superpixels at end

    % detect and display superpixels (see spDetect.m)
    folder_path = strcat(file_path, '/');
    frames_rgb = dir(strcat(folder_path, '*.jpg'));
    nframes = size(frames_rgb, 1);
    factor = 0.8;
    for i = 1 : nframes
        I = imread(strcat(folder_path, frames_rgb(i).name));
        %I = imresize(I, 0.8);
        [E,~,~,segs]=edgesDetect(I,model);
        [S,V] = spDetect(I,E,opts);
        % compute ultrametric contour map from superpixels (see spAffinities.m)
        [~,~,U]=spAffinities(S,E,segs,opts.nThreads);
        %figure(3); 
        %U = imresize(U, 1/0.8);
        %im(U);
        save(fullfile(save_path, sprintf('%04d', i)), 'U');
    end
end