function [] = extractSuperpixel(file_path, save_path, type)
    if strcmp(type, 'rgb')
        model=load('models/forest/modelBsds');
    else
        model=load('models/forest/modelNyuD');
    end
    model=model.model;
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
    if strcmp(type, 'rgb')
        frames = dir(strcat(folder_path, '*.jpg'));
    else
        frames = dir(strcat(folder_path, '*.mat'));
    end
    nframes = size(frames, 1);
    for i = 1 : nframes
        if strcmp(type, 'rgb')
            I = imread(strcat(folder_path, frames(i).name));
        else
            depth = load(strcat(folder_path, frames(i).name));
            I = depth.depth;
        end
        %I = imresize(I, 0.8);
        [E,~,~,segs]=edgesDetect(I,model);
        [S,~] = spDetect(I,E,opts);
        % compute ultrametric contour map from superpixels (see spAffinities.m)
        [~,~,U]=spAffinities(S,E,segs,opts.nThreads);
        %figure(3); 
        U = imresize(U, 0.5);
        %im(U);
        save(fullfile(save_path, sprintf('%04d', i)), 'U');
    end
end