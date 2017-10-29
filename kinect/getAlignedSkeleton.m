%
%	getAlignedSkeleton
%	Author: Baoxiong Jia
%	use:	pass in the return value of getAnchorSkeleton, which are anchor points for each action and skeleton set for each action
%	return:	return the aligned joints matrix (3 * 25) for each skeleton in each action
%
function [action2aligned] = getAlignedSkeleton(action2anchor, action2skeleton, dir_map)
	addpath(genpath('./utils'));
	anchor_index = [5, 9, 13, 17];
	action_cnt = size(action2anchor, 2);
	action2aligned = {};
	for action_idx = 1 : action_cnt
		anchor_dst = action2anchor{action_idx};
		action2aligned{action_idx} = {};
		for skeleton_idx = 1 : size(action2skeleton{action_idx}, 2)
			skeleton = action2skeleton{action_idx}{skeleton_idx}{1};
			dir_name = action2skeleton{action_idx}{skeleton_idx}{3};
			frame = action2skeleton{action_idx}{skeleton_idx}{2};
			
			%[anchor_ori, ori_mask] = getAnchor(skeleton, anchor_index);	
            %[param_w, ~, ~, ~, sof] = helmert3d(anchor_ori', (anchor_dst .* ori_mask)', '7p');
            
            [anchor_ori, ~] = getAnchor(skeleton, anchor_index);
            [param_w, ~, ~, ~, sof] = helmert3d(anchor_ori', anchor_dst', '7p');
			joints = getJoints(skeleton);
			if sof ~= 0
                aligned_joints = d3trafo(joints', param_w, [], 0);
                param_temp = param_w;
            else
                fprintf('frameid %d, dirid %d, action %d, skeleton %d\n', frame, dir_name, action_idx, skeleton_idx);
                aligned_joints = d3trafo(joints', param_temp, [], 0);
                fig = figure();
                plot_skeleton(joints', dir_name, frame, dir_map, 'r')
                plot_skeleton(aligned_joints, dir_name, frame, dir_map, 'g');
                close all;
            end
            action2aligned{action_idx}{skeleton_idx} = aligned_joints'; % return 3 * n
		end
	end
end

function [joints] = getJoints(skeleton)
	joints = [];
	for joint_idx = 1 : 25
		joints = [joints, skeleton{joint_idx}.camera];
	end
end