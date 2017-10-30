%   Main logic stream of the get mean
clc;
clear;

%%
root = '../Dataset';
[action_index, skeleton_mat, dir_map] = getSkeleton(root);

%%
[action2anchor, action2skeleton] = getAnchorSkeleton(skeleton_mat, action_index);

%%
action2aligned = getAlignedSkeleton(action2anchor, action2skeleton, dir_map);
save('action2aligned.mat', 'action2aligned');

%% 
action2mean = getMeanSkeletons(action2aligned);

for action = 1 : size(action2mean, 2)
    if size(action2aligned{action}, 2) ~= 0
        fig = figure();
        plot_skeleton(action2mean{action}', action2skeleton{action}{1}{3}, action2skeleton{action}{1}{2}, dir_map, 'r')
        hold on;
        plot_skeleton(action2aligned{action}{1}', action2skeleton{action}{1}{3}, action2skeleton{action}{1}{2}, dir_map, 'g');
        title(action_index{action});
    end
end