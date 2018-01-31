function [final_selection] = select_sp(seg, foreground, skeleton)
    nseg = max(seg(:)) + 1;
    selected = [];
    if size(skeleton, 1) == 0
        return;
    end
    for seg_idx = 1 : nseg
        [rows, cols] = find(seg == seg_idx - 1);
        count = 0;
        for idx = 1 : length(rows)
            if foreground(rows(idx), cols(idx)) > 0
                count = count + 1;
            end
        end
        if count > 0.5 * length(rows)
            selected = [selected, (seg_idx -1)];
        end
    end 
    final_selection = [];
    for idx = 1 : length(selected)
        if ~check_cover(seg, selected(idx), skeleton)
            final_selection = [final_selection, selected];
        end
    end
    im(foreground);
    visualize(seg, final_selection);

end

function [] = visualize(seg, selected)
    img = zeros(size(seg));
    for sp = 1 : length(selected)
        index = find(seg == selected(sp));
        img(index) = 1;
    end
    im(img);
end

function [active] = check_interactive(seg, seg_idx, skeleton)
    threshold = 50;
    joint_idx = [
                    3, 2, ... % head
                    20, 1, 0, ... % torso
                    19, 18, 17, 16, ... % right leg
                    15, 14, 13, 12, ... % left leg
                    8, 9, ... % right arm
                    4, 5 % left arm
                ] + 1;
    hand_idx = [
                    6, 7, 10, 11, 21, 23, 22, 24
                ];
    joint_pos = skeleton(joint_idx, :);
    
    active = false;
    
    for idx = 1 : length(joint_idx)
        if seg(joint_pos(idx)) == seg_idx
            [rows, cols] = find(seg == seg_idx);
            min_dis = 1920 * 1080;
            for pos_idx = 1 : length(rows)
                % Make sure col sum
                dis = min(sqrt(sum((skeleton(hand_idx, :) - [rows(pos_idx), cols(pos_idx)]) .^ 2)));
                if dis < threshold
                    active = true;
                    break;
                end
            end
            if active
                break;
            end
        end
    end
end