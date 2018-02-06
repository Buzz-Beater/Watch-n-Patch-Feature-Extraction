
addpath('skeleton');
%{
addpath('visual');
addpath(genpath('visual/superpixel'));
addpath(genpath('visual/superpixel/utils'));
addpath(genpath('visual/foreground'));
run('visual/foreground/lrslibrary/lrs_setup');
addpath('visual/foreground/STOC-RPCA');
addpath('visual/superpixel')
%}
root = '../Dataset';

%{
% Skeleton feature extraction
traverse_dir(root, 'skeleton', '');

% Foreground extraction for rgb images and depth images
traverse_dir(root, 'foreground', 'rgbjpg');
traverse_dir(root, 'foreground', 'rgbjpg');

% Superpixel segmentation for rgb images and depth images
traverse_dir(root, 'superpixel', 'rgbjpg');
traverse_dir(root, 'superpixel', 'depth');

% Merging superpixel segments and getting final feature for each frame
traverse_dir(root, 'select_sp', 'depth');
%}
%traverse_dir(root, 'select_sp', '')

% Visualization
traverse_dir(root, 'visualize', '');