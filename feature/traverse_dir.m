%   getSkeletonFeature
%   Author: Baoxiong Jia
%   use:    pass in the root directory of the dataset 
%           (e.g. if ../Dataset/kitchen1 or ../Dataset/kitchen2 is your directory accordingly, 
%           please set root to be '../Dataset')
%   return: action_index -- for total 59 action labels, action_index(i)
%                           will return the string indicating the i-th
%                           action class label. (the first 43 indices relates to office_classnames
%                           the last 16 relates to kitchen class names)
%           skeleton_mats   the reformated skeleton data
%                               - dir_index (the id of the folder, merged all office and kitchen data dirs then indexed)
%                               - frame_index (the frame)
%                                   - struct {person_id, raw_joint_data, action_label}
%           dir_map         with dir_map{i} we can have the i-th directory name in the merged indexation
%
function [] = traverse_dir(root, fea_type, img_type)
	class_names = {'office', 'kitchen1', 'kitchen2'};
	data_paths = {fullfile(root, class_names{1}), fullfile(root, class_names{2}), fullfile(root, class_names{3})};

	office_dir = dir([data_paths{1}]);
	office_dir = office_dir(3 : end);
	kitchen_dir1 = dir([data_paths{2}]);
	kitchen_dir1 = kitchen_dir1(3 : end);
	kitchen_dir2 = dir([data_paths{3}]);
	kitchen_dir2 = kitchen_dir2(3 : end);

	data_dirs = {office_dir, kitchen_dir1, kitchen_dir2};
	dir_cnt = {size(office_dir, 1), size(kitchen_dir1, 1), size(kitchen_dir2, 1)};
	dir_total = size(office_dir, 1) + size(kitchen_dir1, 1) + size(kitchen_dir2, 1);

	for dir_class = 1 : 3
		for dir_idx = 1 : dir_cnt{dir_class}
   			dir_name = data_dirs{dir_class}(dir_idx).name;
			file_path = fullfile(data_paths{dir_class}, dir_name);
            rel_path = fullfile(class_names{dir_class}, dir_name);
			save_path = fullfile(root, 'features_temp', fea_type, class_names{dir_class}, dir_name);
			%if ~exist(save_path)
			%	mkdir(save_path);
            %end
            mkdir(save_path);
            tic;
			if strcmp(fea_type, 'skeleton')
                fprintf('In %s/%s:\n', class_names{dir_class}, dir_name);
				extractSkeletonFeature(file_path, save_path);
			elseif strcmp(fea_type, 'foreground')
                extractForegroundMask(fullfile(file_path, img_type), save_path, img_type);
			elseif strcmp(fea_type, 'superpixel')
				extractSuperpixel(fullfile(file_path, img_type), save_path, img_type);
            elseif strcmp(fea_type, 'select_sp')
            	% Here code is specific designed for rgb
            	% For depth images, use 'depth' in body2matrix_mod and 'depth' in sp_path
                save_rt = fullfile(root, 'features', 'merged', rel_path);
                mkdir(save_rt);
            	imgs = dir([fullfile(file_path, 'rgbjpg')]);
            	img_path = imgs(3 : end);
    
            	body = load(fullfile(file_path, 'body.mat'));
            	body = body.body;
                for idx = 1 : length(img_path)
                   tic;
                   img_types = {'rgbjpg', 'depth'};
                   skeleton_fea_file = load(fullfile(root, 'features', 'skeleton', rel_path, 'skeleton_features.mat'));
                   skeleton_fea = skeleton_fea_file.features;
                   fprintf('In %s, %s %d, %d %d\n', class_names{dir_class}, dir_name, dir_idx, idx, size(skeleton_fea, 1))
                   concat_feature = skeleton_fea(idx, :);
                    %fprintf('concat init size : %d\n', size(concat_feature, 2));
                   for type_idx = 1 : length(img_types)
                        img_type = img_types{type_idx};
                        if strcmp(img_type, 'rgbjpg')
                            field = 'color';
                            kernels = {'nrgbkdes', 'gradkdes', 'lbpkdes'};
                        else
                            field = 'depth';
                            kernels = {'gradkdes_dep', 'normalkdes'};
                        end
                        skeleton = body2matrix_mod(body, field);
                        for k_idx = 1 : length(kernels)
                            segfea_path = fullfile(root, 'features', 'kdes', kernels{k_idx}, rel_path, [num2str(idx, '%04d') '.mat']);
                            segfea_file = load(segfea_path);
                            segfea = segfea_file.kdes;	
                            foreground_path = fullfile(root, 'features', 'foreground', 'rgbjpg', rel_path, [num2str(idx, '%04d') '.mat']);
                            sp_path = fullfile(root, 'features', 'superpixel', img_type, rel_path, [num2str(idx, '%04d') '.mat']);
                            mask_file = load(foreground_path);
                            sp_file = load(sp_path);
                            foreground = mask_file.Tmask;
                            if strcmp(img_type, 'rgbjpg')
                              seg = sp_file.seg;
                            else
                                ucm = sp_file.U;
                                seg = bwlabel(ucm <= 0.13);
                            end
                            foreground = imresize(foreground, size(seg));
                            if strcmp(img_type, 'depth')
                                additional_foreground = fullfile(root, 'features', 'foreground', 'depth', rel_path, [num2str(idx, '%04d') '.mat']);
                                mask_file = load(additional_foreground);
                                foreground = foreground + mask_file.Tmask;
                            end
                            skeleton_ = reshape(skeleton(idx, :, :), [size(skeleton(idx, :, :), 2), size(skeleton(idx, :, :), 3)]);
                            if field == 'color'
                                skeleton_ = skeleton_ ./ 2;
                            end
                            [selected] = select_sp(seg, foreground, skeleton_);
                            feature = merge_sp(segfea, seg, selected, kernels{k_idx});
                            if size(feature, 2) ~= 400
                                fprintf('invalid kernel size : %d\n', size(feature, 2));
                            end
                            concat_feature = [concat_feature, feature];
                        end
                    end
                    save_concat_features([save_rt '/' num2str(idx, '%04d') '.mat'], concat_feature, selected);
                    toc;
                end
            stop = toc;
            fprintf('extracting %s for %s, took %fs\n', fea_type, file_path, stop);
		end
	end
end
