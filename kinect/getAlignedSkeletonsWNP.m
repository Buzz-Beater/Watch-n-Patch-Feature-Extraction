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