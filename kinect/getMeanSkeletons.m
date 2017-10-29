function [action2mean] = getMeanSkeletons(action2aligned)
    action2mean = cell(size(action2aligned, 2));
    for action_idx = 1 : size(action2aligned, 2)
        action2mean{action_idx} = zeros(size(action2aligned{action_idx}{1}, 2));
        for skeleton_idx = 1 : size(action2aligned{action_idx}, 2)
            aligned = action2aligned{action_idx}{skeleton_idx};
            action2mean{action_idx} = action2mean{action_idx} + aligned;
        end
        action2mean{action_idx} = action2mean{action_idx} ./ size(action2aligned{action_idx}, 2);
    end
end