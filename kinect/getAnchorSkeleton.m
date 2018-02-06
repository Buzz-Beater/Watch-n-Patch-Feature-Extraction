%    getAnchorSkeleton
%    Author:  Baoxiong Jia
%    use: pass in the parameter as the return value from getSkeleton
%            skeletons ---- the extracted skeleton meta, skeletons{dir_idx}{frame_idx} = skeleton_info
%            action_index ---- merged action labels, for convenience of showing the actual string
%    return: action2anchor ---- for each action, if there are labeled action skeletons, return the anchor point (3 * anchor_cnt)
%            action2skeleton ---- for each action, access action2skeleton{action_idx}, we can have all skeleton labeled as action_index(action_idx)
function [action2anchor, action2skeleton] = getnchorSkeleton(skeletons, action_index)
	total_action = size(action_index, 2) + 1;
	action2skeleton = {};
	for action = 1 : total_action
		action2skeleton{action} = {};
	end

	dir_cnt = size(skeletons, 2);
	action_idx = ones(1, total_action);
	for dir_idx = 1 : dir_cnt
		frame_cnt = size(skeletons{dir_idx}, 2);
		for frame_idx = 1 : frame_cnt
			skeleton = skeletons{dir_idx}{frame_idx};
      		if size(skeleton, 1) ~= 0
        		skeleton = skeleton{1};
			  	action = skeleton{3};
			  	action2skeleton{action}{action_idx(action)} = {skeleton{2}, frame_idx, dir_idx};
			  	action_idx(action) = action_idx(action) + 1;
      		end
		end
	end

	% currently take shoulder-left, shoulder-right, hip-left, hip-right as anchor points
    % the skeleton's mean for each action's joint data is taken as anchor point
	% we can take spine-base ---- 1 as base
	anchor_index = [5, 9, 1];
	action2anchor = {};
	for action = 1 : total_action
		%anchor_cnt = zeros(1, size(anchor_index, 2));
        action2anchor{action} = [];
		% choose the skeletons' mean of each action as anchors
		if size(action2skeleton{action}, 2) > 0	
			anchor_point = zeros(3, size(anchor_index, 2));
            %{
			for skeleton_idx = 1 : size(action2skeleton{action}, 2)
				anchor_skeleton = action2skeleton{action}{skeleton_idx}{1};
				%{
                % in case some skeletons doesn't have anchor points
				[anchor_tmp, anchor_mask] = getAnchor(anchor_skeleton, anchor_index);
				anchor_point += anchor_tmp;
				anchor_cnt += anchor_mask
                %}
                [anchor_tmp, ~] = getAnchor(anchor_skeleton, anchor_index);
                anchor_point = anchor_point + anchor_tmp;
			end
			%anchor_point = anchor_point ./ anchor_cnt;
            anchor_point = anchor_point ./ size(action2skeleton{action}, 2);
			%}
            [anchor_point, ~] = getAnchor(action2skeleton{action}{1}{1}, anchor_index);
            action2anchor{action} = [action2anchor{action} anchor_point];
		end
	end
end