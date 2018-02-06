function [] = visualize(img_path, seg_path, selection_path, save_path, skeleton)
	imgs = dir([img_path]);
    imgs = imgs(3 : end);
    skeleton  = skeleton ./ 2;
    fig = figure;
	for img_idx = 1 : length(imgs)
		img = imread([img_path '/' num2str(img_idx, '%04d') '.jpg']);
	    seg_file = load([seg_path '/' num2str(img_idx, '%04d') '.mat']);
	    seg = seg_file.seg;
	    sel_file = load([selection_path '/' num2str(img_idx, '%04d') '.mat']);
	    selected = sel_file.features;
	    img = imresize(img, size(seg));
	    skeletonData = reshape(skeleton(img_idx, :, :), [size(skeleton(img_idx, :, :), 2), size(skeleton(img_idx, :, :), 3)]);
        if ~isempty(selected)
            for sp = 1 : length(selected)
                index = find(seg == selected(sp));
            	r = img(:, :, 1);
            	g = img(:, :, 2);
            	b = img(:, :, 3);
            	r(index) = 0;
            	g(index) = 255;
            	b(index) = 0;
            	img = cat(3, r, g, b);
            end
            plotColor = 'r';
            imshow(img);
            hold on;
            index = [
                    24, 11; 24, 11; 11, 10; 10, 9; 9, 8; 8, 20;... % right arm
                    21, 7; 22, 7; 7, 6; 6, 5; 5, 4; 4, 20;... % left arm
                    3, 2; 2, 20;... % head
                    20, 1; 1, 0;... % torso
                    19, 18; 18, 17; 17, 16; 16, 0;... % right leg
                    15, 14; 14, 13; 13, 12; 12, 0;... % left leg
                ] + 1;

            for i = 1:size(index, 1)
                line([skeletonData(index(i, 1), 1), skeletonData(index(i, 2), 1)], [skeletonData(index(i, 1), 2), skeletonData(index(i, 2), 2)], ...
                                        'Color', plotColor, 'LineWidth', 3, 'lineStyle', '-');
                hold on;
            end
            hold off;
            %plot(skeletonData(9, 1), skeletonData(9, 2), '.','Color','y','markers',12);
            export_fig(fig, [save_path '/' num2str(img_idx, '%04d') '.png']);
        end
	end
    close all;
    clear all;
end