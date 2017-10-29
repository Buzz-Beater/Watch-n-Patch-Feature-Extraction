data_paths = {'./Dataset/office', './Dataset/kitchen1', './Dataset/kitchen2'};
class_paths = {'./Dataset/office_class', './Dataset/kitchen_class', './Dataset/kitchen_class'};
class_name = {'office_classname', 'kitchen_classname', 'kitchen_classname'};
office_dir = dir([data_paths{1}]);
office_dir = office_dir(3 : end);
kitchen_dir1 = dir([data_paths{2}]);
kitchen_dir1 = kitchen_dir1(3 : end);
kitchen_dir2 = dir([data_paths{3}]);
kitchen_dir2 = kitchen_dir2(3 : end);

data_dirs = {office_dir, kitchen_dir1, kitchen_dir2};
addpath(genpath('kinect/utils'));
dir_cnt = {size(office_dir, 1), size(kitchen_dir1, 1), size(kitchen_dir2, 1)};

skeleton_mats = {};
body_mats = {};
action_mats = {};

% Load data and compute mean skeleton
idx = 1;  % from 1 to sum(dir_cnt)
for dir_name = 1 : 3 
  for dir_idx = 1 : dir_cnt{dir_name}
    body = load(fullfile(data_paths{dir_name}, data_dirs{dir_name}(dir_idx).name, 'body.mat')).body;
    action_label = load(fullfile(class_paths{dir_name}, data_dirs{dir_name}(dir_idx).name, 'gnd.mat')).gnd;
    frames = size(body, 1);
    persons = size(body, 2);
    skeleton_mats{idx} = {}
    
    skeleton_idx = 1;
    for frame = 1 : frames
      skeleton_mats{idx}{frame} = {}
      for person = 1 : persons
        cur_skeleton = body{frame, person};
        if cur_skeleton.isBodyTracked != 0
          skeleton_mats{idx} = {frame, person, cur_skeleton.joints, class_name{dir_name}, action_label};
        end
      end
    end
    idx++;
  end
end

% reshape the third field of the skeleton_mats to 25 * 3 point matrix
% Calculate mean skeleton
function [mean_skeleton] = getMeanSkeleton(skeleton_mats)
  mean = zeros(size(skeleton_mats, 1), 3);
  invalid_cnt = 0;
  for idx = 1 : size(skeleton_mats, 1)
    joints = skeleton_mats{idx}{3};
    flag = true;
    for joint_idx = 1 : size(joints, 1)
      if joints{joint_idx}.trackingState == 0
        flag = false;
        invalid_cnt++;
      end
    end
    if flag
      for joint_idx = 1 : size(joints, 1)
        % instead of cm, use the standard mm, wonder where the 20 came from
        mean(joint_idx, :) += (joints{joint_idx}.pcloud / 1000);
      end
    end
    mean = mean ./ (size(skeleton_mats, 1) - invalid_cnt);
  end
  mean_skeleton = mean;
end 

function [aligned_skeletons] = alignSkeletons(skeleton_mats, anchor_set, mean_skeleton)
  anchor_mean = zeros(sizeof(anchor_set, 1), 3);
end
  
end