function [anchor_point] = getAnchor(skeleton, anchor_index)
	anchor_point = [];
	for anchor_idx = 1 : size(anchor_index, 2)
		% use camera coordinate or depth world coordinate, still needs to be determined
		anchor_point = [anchor_point, skeleton{anchor_index(anchor_idx)}.camera];
	end
end