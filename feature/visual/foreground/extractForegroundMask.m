function [] = extractForegroundMask(file_path, save_path)
    folder_frames_rgb = fullfile(file_path, '/');
    d_frames_rgb = dir(strcat(folder_frames_rgb,'*.jpg'));
    nframes = size(d_frames_rgb,1);
    factor = 0.4; % input_size = [120 120];
    k = 0;
    for i = 1:nframes
        k = k + 1;
        %disp(['frame: ' num2str(i)]);
        filename_rgb = strcat(folder_frames_rgb,d_frames_rgb(i).name);
        
        input_rgb = im2double(imread(filename_rgb));
        input_rgb = imresize(input_rgb,factor);
        frame = input_rgb;
        
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
