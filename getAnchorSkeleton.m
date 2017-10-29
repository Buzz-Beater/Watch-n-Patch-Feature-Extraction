%%% problem ----- some fields of action2skeleton are {}(0 * 0)
function [action2anchor, action2skeleton] = getMeanSkeleton(skeletons, action_index)
	total_action = size(action_index, 2) + 1;
	action2skeleton = {};
	for action = 1 : total_action
		action2skeleton{action} = {};
	end

	dir_cnt = size(skeletons, 1);
	action_idx = ones(1, total_action);
	for dir_idx = 1 : dir_cnt
		frame_cnt = size(skeletons{dir_idx}, 1)
		for frame_idx = 1 : frame_cnt
			skeleton = skeletons{dir_idx}{frame_idx}{1};
			action = skeleton{3};
			action2skeleton{action}{action_idx(action)} = skeleton{2};
			action_idx(action) += 1;
		end
	end

	% currently take shoulder-left, shoulder-right, hip-left, hip-right as anchor points
	% we can take spine-base ---- 1 as base
	anchor_index = [5, 9, 13, 17];
	action2anchor = {};
	for action = 1 : total_action
		action2anchor{action} = [];
		% choose the first skeleton of each action as anchors
		if size(action2skeleton{action}, 2) > 0
			anchor_skeleton = action2skeleton{action}{1};
			for anchor_idx = 1 : size(anchor_index, 2)
				% use camera coordinate or depth world coordinate, still needs to be determined
				anchor_point = anchor_skeleton{anchor_index(anchor_idx)}.camera;
				%anchor_point = anchor_skeleton.camera
				action2anchor{action} = [action2anchor{action} anchor_point];
			end
			action2skeleton{action} = action2skeleton(2 : end);
		end
	end
  action2anchor
  action2skeleton
end