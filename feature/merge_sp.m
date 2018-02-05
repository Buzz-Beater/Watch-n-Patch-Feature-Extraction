function [feature] = merge_sp(segfea, seg, selected, kernel)
	if contains(kernel, 'normal') || contains(kernel, 'spin')
		patch_size = 40;
	else
		patch_size = 16;
	end
	grid_space = 8;
	wseg = get_kdes_weight_seg(seg, grid_space, patch_size);
	wseg2 = sum(wseg(selected + 1));
	nfeature = size(segfea, 1);
	feature = zeros(1, nfeature);
	if length(selected) == 0
		return;
	elseif length(selected) == 1
		feature = segfea(:, selected + 1)';
	else
		for t = 1 : length(selected)
			feature = feature + wseg(selected + 1)'* segfea(:, selected + 1)';
		end
		feature = feature ./ wseg2;
	end
end


function W=get_kdes_weight_seg(seg, grid_space, patch_size)
	%
	% function get_kdes_weight_seg(seg, grid_space, patch_size)
	%

	nseg=max(seg(:))+1;
	mpatch_size = max(patch_size); % maximum patch size
	[im_h, im_w] = size(seg);
	rem_x = mod(im_w-mpatch_size, grid_space);
	offset_x = floor(rem_x/2)+1;
	rem_y = mod(im_h-mpatch_size, grid_space);
	offset_y = floor(rem_y/2)+1;
	[grid_x, grid_y] = meshgrid(offset_x:grid_space:im_w-mpatch_size+1, offset_y:grid_space:im_h-mpatch_size+1);

	grid_x=round( grid_x + patch_size/2 - 0.5 );
	grid_y=round( grid_y + patch_size/2 - 0.5 );

	ind=sub2ind([im_h im_w],grid_y,grid_x);
	ind=ind(:);

	n=accumarray( seg(ind)+1, ones(size(ind)), [nseg 1] );
	W=n;
end