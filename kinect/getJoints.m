function [joints] = getJoints(skeleton)
	joints = [];
	for joint_idx = 1 : 25
		joints = [joints, skeleton{joint_idx}.camera];
	end
end