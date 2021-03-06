%
%   body2matrix
%   Author: Baoxiong Jia
%   use:    pass in the body struct in the Watch-n-Patch body.mat
%   return: return (frames * joints * 3d) matrix
%
function [body_mat] = body2matrix(body)
    joint_cnt = 25;
    dimension = 3;
    body_mat = zeros(size(body, 1), joint_cnt, dimension);
    for frame_idx = 1 : size(body, 1)
        track_flag = 0;
        body_tmp = zeros(joint_cnt, dimension);
        has_morethan1 = false;
        has_skeleton = false;
        for person_idx = 1 : size(body, 2)
            cur_skeleton = body{frame_idx, person_idx};
            if cur_skeleton.isBodyTracked ~= 0
                track_flag = 1;
                if has_morethan1
                    fprintf('    has more than 1 person in %d frame\n', frame_idx);
                end
                has_morethan1 = true;
                has_skeleton = true;
                joints = cur_skeleton.joints;
                for joint_idx = 1 : joint_cnt
                    body_tmp(joint_idx, :) = (joints{joint_idx}.camera)';
                end
            end
        end
        if ~has_skeleton
            fprintf('       frame %d has no skeleton\n', frame_idx);
        end
        body_mat(frame_idx, :, :) = body_tmp;
    end
    fprintf('   Total frame in this video is %d\n', size(body, 1))
end
