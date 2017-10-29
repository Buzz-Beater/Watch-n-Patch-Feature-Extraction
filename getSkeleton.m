function [action_index, skeleton_mats] = getSkeleton()
	data_paths = {'./Dataset/office', './Dataset/kitchen1', './Dataset/kitchen2'};
	class_paths = {'./Dataset/office_class', './Dataset/kitchen_class', './Dataset/kitchen_class'};
	office_labels = load('./Dataset/office_classname.mat');
	kitchen_labels = load('./Dataset/kitchen_classname.mat');
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

	skeleton_mats = {};
	body_mats = {};
	action_mats = {};

	% Load data and compute mean skeleton
	idx = 1;  % from 1 to sum(dir_cnt)
	for dir_name = 1 : 3 
		for dir_idx = 1 : dir_cnt{dir_name}
      fprintf('Reformating skeleton data for %s directory %d\n', data_paths{dir_name}, dir_idx);
			body = load(fullfile(data_paths{dir_name}, data_dirs{dir_name}(dir_idx).name, 'body.mat')).body;
			action_labels = load(fullfile(class_paths{dir_name}, data_dirs{dir_name}(dir_idx).name, 'gnd.mat')).gnd;
			frames = size(body, 1);
			persons = size(body, 2);
			skeleton_mats{idx} = {};
			
			% skeleton_mat follows the structure
			% skeleton_mat{directory_idx}{frame_idx}{person_idx}

			for frame = 1 : frames
				skeleton_mats{idx}{frame} = {};
				person_idx = 1;
				if action_labels(frame, 1) == 0
					action_label = size(action_index, 2) + 1;
				else
          if dir_name == 1
            action_label = action_labels(frame, 1);
					  %action_label = (class_name{dir_name}.office_classname){action_labels(frame, 1)};
				  else
            action_label = action_labels(frame, 1) + size(office_labels.office_classname, 2);
            %action_label = (class_name{dir_name}.kitchen_classname){action_labels(frame, 1)};
          end
        end 
				for person = 1 : persons
					cur_skeleton = body{frame, person};
					if cur_skeleton.isBodyTracked ~= 0
						skeleton_mats{idx}{frame}{person_idx} = {person, cur_skeleton.joints, action_label};
						++person_idx;
					end
				end
			end
			++idx;
		end
	end
end