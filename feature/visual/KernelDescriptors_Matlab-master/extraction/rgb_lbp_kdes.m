function [] = rgb_lbp_kdes(data_path)
	
	addpath('../helpfun');
	addpath('../kdes');

	img_subdir = dir_bo(data_path);
	img_path = cell(length(img_subdir), 1);

	for i = 1 : length(img_subdir)
		img_path{i} = fullfile(data_path, img_subdir(i).name);
    end
    
	% initialize the parameters of kdes
	kdes_params.grid = 8;   % kdes is extracted every 8 pixels
	kdes_params.patchsize = 16;  % patch size
	load('lbpkdes_params');
	kdes_params.kdes = lbpkdes_params;

	% initialize the parameters of data
	data_params.datapath = img_path;
	data_params.tag = 1;
	data_params.minsize = 45;  % minimum size of image
	data_params.maxsize = 300; % maximum size of image
	data_params.savedir = ['../kdesfeatures/rgbd' 'lbpkdes'];

    % extract kernel descriptors
    mkdir_bo(data_params.savedir);
    rgbdkdespath = get_kdes_path(data_params.savedir);
    if ~length(rgbdkdespath)
        gen_kdes_batch(data_params, kdes_params);
        rgbdkdespath = get_kdes_path(data_params.savedir);
    end

end