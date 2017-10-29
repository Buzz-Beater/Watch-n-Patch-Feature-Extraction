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

%% 
action2mean = getMeanSkeleton(action2aligned);