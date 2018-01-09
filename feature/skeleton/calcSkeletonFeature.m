%   
%   Function:   getBody
%   Author:     Baoxiong Jia
%   Usage:      pass in the directory name then return the skeleton
%   features
function [features] = calcSkeletonFeature(file_path)
    body = load(file_path);
    body_mat = body2matrix(body.body);
    features = compute_feature(body_mat);
end

% Uniform interface for skeleton feature computation
function [features] = compute_feature(body_mat)
    angle_features = calc_angle(body_mat);
    motion_features = calc_motion(body_mat, angle_features);
    offset_features = calc_offset(body_mat, angle_features);
    features = [angle_features, motion_features, offset_features];
end

% Angle between torso, limbs and related body parts
function [angle_features] = calc_angle(body_mat)
    connected_parts = [[24, 11, 10]; [23, 11, 10]; [11, 10, 9]; [10, 9, 8]; [9, 8, 20]; ... % right arm
    					[5, 4, 20]; [6, 5, 4]; [7, 6, 5]; [21, 7, 6]; [22, 7, 6]; ... % left arm
    					[3, 2, 20]; [2, 20, 1]; [20, 1, 0]; ... % torso
    					[1, 0, 16]; [0, 16, 17]; [16, 17, 18]; [17, 18, 19]; ... % right leg
    					[1, 0, 12]; [0, 12, 13]; [12, 13, 14]; [13, 14, 15]]; % left leg
   	% Transform kinect index to matlab index
	connected_parts = connected_parts + 1;
	% Return frame * angle_number feature
   	angle_features = zeros(size(body_mat, 1), size(connected_parts, 1));
   	for frame = 1 : size(body_mat, 1)
   		for set_idx = 1 : size(connected_parts, 1)
   			points = body_mat(frame, connected_parts(set_idx, :), :);
   			x_1 = squeeze(points(1, 2, :) - points(1, 1, :));
   			x_2 = squeeze(points(1, 2, :) - points(1, 3, :));
   			angle_features(frame, set_idx) = dot(x_1, x_2) / (norm(x_1) * norm(x_2));
   		end
   	end
end

% Motion for body joints, measured by the spatial location difference between frame t and frame t-1
function [motion_features] = calc_motion(body_mat, angle_features)
	motion_features = zeros(size(body_mat, 1), size(body_mat, 2) + size(angle_features, 2));
	motion_features(1, :) = ones(1, size(body_mat, 2) + size(angle_features, 2));
	for frame = 2 : size(body_mat, 1)
        prev_skeleton = squeeze(body_mat(frame - 1, :, :))';
        cur_skeleton = squeeze(body_mat(frame, :, :))';
        motion_distance = sqrt(sum((cur_skeleton - prev_skeleton) .^ 2));
		angle_distance = sqrt((angle_features(frame, :) - angle_features(frame - 1, :)) .^ 2);
		motion_features(frame, :) = [motion_distance, angle_distance];
	end
end

% Offset for body joints, measured by the spatial location difference between frame t and frame 1
function [offset_features] = calc_offset(body_mat, angle_features)
	offset_features = zeros(size(body_mat, 1), size(body_mat, 2) + size(angle_features, 2));
	offset_features(1, :) = ones(1, size(body_mat, 2) + size(angle_features, 2));
	for frame = 2 : size(body_mat, 1)
        init_skeleton = squeeze(body_mat(1, :, :))';
        cur_skeleton = squeeze(body_mat(frame, :, :))';
		offset_motion = sqrt(sum((cur_skeleton - init_skeleton) .^ 2));
		offset_angle = sqrt((angle_features(frame, :) - angle_features(1, :)) .^ 2);
		offset_features(frame, :) = [offset_motion, offset_angle];
	end
end
