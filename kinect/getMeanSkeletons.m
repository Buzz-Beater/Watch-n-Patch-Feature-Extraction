%
%   getMeanSkeletons
%   Author: Baoxiong Jia
%   use:    pass in the aligned action skeletons 
%           action2aligned - 1 * action_cnt cell
%           action2aligned{i} - 1 * skeleton_in_this_action_cnt cell
%           action2aligned{i}{j} - 3 * 25 matrix
%   return: action2mean - 1 * action_cnt cell
%           action2mean{i} - 3 * 25 matrix
%
function [action2mean] = getMeanSkeletons(action2aligned)
    action2mean = cell(size(action2aligned, 2));
    for action_idx = 1 : size(action2aligned, 2)
        action2mean{action_idx} = zeros(size(action2aligned{action_idx}{1}));
        for skeleton_idx = 1 : size(action2aligned{action_idx}, 2)
            aligned = action2aligned{action_idx}{skeleton_idx};
            action2mean{action_idx} = action2mean{action_idx} + aligned;
        end
        action2mean{action_idx} = action2mean{action_idx} ./ size(action2aligned{action_idx}, 2);
    end
end