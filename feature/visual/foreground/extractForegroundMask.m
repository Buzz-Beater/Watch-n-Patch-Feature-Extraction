function [] = extractForegroundMask(file_path, save_path, type)
    folder_frames_rgb = fullfile(file_path, '/');
    if strcmp(type, 'rgbjpg')
        d_frames = dir(strcat(folder_frames_rgb,'*.jpg'));
    else
        d_frames = dir(strcat(folder_frames_rgb, '*.mat'));
    end
    nframes = size(d_frames,1);
    rgb_factor = 0.4; % input_size = [120 120];
    k = 0;
    for i = 1:nframes
        k = k + 1;
        %disp(['frame: ' num2str(i)]);
        filename_rgb = strcat(folder_frames_rgb,d_frames(i).name);
        if strcmp(type, 'rgbjpg')
            input_rgb = im2double(imread(filename_rgb));
            input_rgb = imresize(input_rgb,rgb_factor);
            frame = input_rgb;
        else
            depth_file = load(filename_rgb);
            depth_img = depth_file.depth;
            frame = im2double(depth_img);
        end
        
        T = tensor(frame);
        if(k == 1) Tm = []; end
        [~,~,Tmask,Tm] = OSTD(T,k,Tm);
        %%% Save outputs
        %[~,filename_out,~] = fileparts(filename_rgb);
        %ilepath_out = strcat(folder_out,'fg',filename_out(3:end),'.png');
        filepath_out = fullfile(save_path, sprintf('%04d', i));
        save(filepath_out, 'Tmask');
        img = strcat(filepath_out, '.png');
    end
