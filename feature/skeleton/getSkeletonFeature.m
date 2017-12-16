%   getSkeleton
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
function [features, index2dir] = getSkeleton(root)
	data_paths = {fullfile(root, 'office'), fullfile(root, 'kitchen1'), fullfile(root, 'kitchen2')};
	class_paths = {fullfile(root, 'office_class'), fullfile(root, 'kitchen_class'), fullfile(root, 'kitchen_class')};
	office_labels = load(fullfile(root, 'office_classname.mat'));
	kitchen_labels = load(fullfile(root, 'kitchen_classname.mat'));
	class_name = {office_labels, kitchen_labels, kitchen_labels};
  	action_index = [office_labels.office_classname, kitchen_labels.kitchen_classname];
	office_dir = dir([data_paths{1}]);
	office_dir = office_dir(3 : end);
	kitchen_dir1 = dir([data_paths{2}]);
	kitchen_dir1 = kitchen_dir1(3 : end);
	kitchen_dir2 = dir([data_paths{3}]);
	kitchen_dir2 = kitchen_dir2(3 : end);

	data_dirs = {office_dir, kitchen_dir1, kitchen_dir2};
	dir_cnt = {size(office_dir, 1), size(kitchen_dir1, 1), size(kitchen_dir2, 1)};
	dir_total = size(office_dir, 1) + size(kitchen_dir1, 1) + size(kitchen_dir2, 1);
	% store dir related information for each feature matrix
	index2dir = cell(1, dir_total);
	% 113 = 21 angles + (25 joints + 21 angles) * 2
	features = zeros(dir_total, 113);

	% Load data and compute mean skeleton
	idx = 1;  % from 1 to sum(dir_cnt)
	for dir_name = 1 : 3 
		for dir_idx = 1 : dir_cnt{dir_name}
      		fprintf('Reformating skeleton data for %s directory %d\n', data_paths{dir_name}, dir_idx);
			file_path = fullfile(data_paths{dir_name}, data_dirs{dir_name}(dir_idx).name, 'body.mat');
			features(idx, :) = calcSkeletonFeature(file_path);
			index2dir(idx) = {dir_name, dir_idx, file_path};
            idx = idx + 1;
		end
	end
end
