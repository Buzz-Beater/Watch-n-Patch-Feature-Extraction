%
%   getAnchor
%   Author: Baoxiong Jia
%   use:    pass in raw watch-n-patch skeleton data, and also the list of
%           anchor index that we want to have (e.g. [enum('hipleft'), enum('hipright'), enum('shoulderleft')....])
%   return: 3 * n matrix, where n is the number of anchors indicated in anchor_index
%
function [anchor_point, anchor_mask] = getAnchor(skeleton, anchor_index)
	anchor_point = zeros(3, size(anchor_index,2));
	anchor_mask = zeros(size(anchor_index, 2));
	for anchor_idx = 1 : size(anchor_index, 2)
		% use camera coordinate or depth world coordinate, still needs to be determined
		%{
        if skeleton{anchor_index(anchor_idx)}.trackingState ~= 0
			anchor_mask(1, anchor_idx) = 1;
			anchor_point = [anchor_point, skeleton{anchor_index(anchor_idx)}.camera];
		else
			anchor_point = [anchor_point, zeros(3, 1)];
        end
        %}
        anchor_point(:, anchor_idx) = skeleton{anchor_index(anchor_idx)}.camera;
	end
end