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
function [] = traverse_dir(root, fea_type)
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

	for dir_class = 3 : 3
		parfor dir_idx = 1 : dir_cnt{dir_class}
   			dir_name = data_dirs{dir_class}(dir_idx).name;
			file_path = fullfile(data_paths{dir_class}, dir_name);
			save_path = fullfile(root, 'features', fea_type, class_names{dir_class}, dir_name);
			%if ~exist(save_path)
			%	mkdir(save_path);
            %end
            mkdir(save_path);
            tic;
			if strcmp(fea_type, 'skeleton')
				extractSkeletonFeature(file_path, save_path);
			elseif strcmp(fea_type, 'foreground')
                extractForegroundMask(fullfile(file_path, 'rgbjpg'), save_path);
			elseif strcmp(fea_type, 'superpixel')
				extractSuperpixel(fullfile(file_path, 'rgbjpg'), save_path);
            end
            stop = toc;
            fprintf('extracting %s for %s, took %fs\n', fea_type, file_path, stop);
		end
	end
end
