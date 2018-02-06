%
%	plot_skeleton
%	Author: Baoxiong Jia
%	use:	plot the skeletonm
%				joints ---- (25 * 3) matrix indicating joint coordinates
%				dir_name ---- the dir of the current skeleton, for the use of depth/rgb image loading
%				frame ---- the frame number of the current skeleton
%

function [] = plot_skeleton(joints, dir_idx, frame, dir_map, color)
	addpath(genpath('./tools'));
	addpath(genpath('./utils'));
    dir_name = dir_map{dir_idx};
	depth_img = load(sprintf('%s/depth/%s.mat', dir_name, num2str(frame, '%04d')));
    depth_img = depth_img.depth;
	rgb_img = imread(sprintf('%s/rgbjpg/%s.jpg', dir_name, num2str(frame, '%04d')));
	depth_pcloud = depth_plane2depth_world(depth_img);
	visualize_point_cloud(depth_pcloud/1000,100*ones(size(depth_pcloud))',20);
    hold on;
    plot3dSkeleton(joints, color);
end