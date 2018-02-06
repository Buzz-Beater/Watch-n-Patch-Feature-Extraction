function [final_selection] = select_sp(seg, foreground, skeleton)
    nseg = max(seg(:)) + 1;
    final_selection = [];
    selected = [];
    if size(skeleton, 1) == 0
        return;
    end
    if sum(skeleton) == 0
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
        if check_interactive(seg, selected(idx), skeleton)
            final_selection = [final_selection, selected(idx)];
        end
    end
end


function [active] = check_interactive(seg, seg_idx, skeleton)
    threshold = 30;
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
                ] + 1;
    joint_pos = skeleton(joint_idx, :);
    
    active = true;
    
    for idx = 1 : size(joint_idx, 2)
        row_ = round(joint_pos(idx, 2));
        col_ = round(joint_pos(idx, 1));
        
        if row_ > size(seg, 1)
            %fprintf('illegal row_ %d', joint_pos(idx, 2));
            row_ = size(seg, 1);
        end
        if row_ < 1
            %fprintf('illegal row_ %d', joint_pos(idx, 2));
            row_ = 1;
        end
        
        if col_ > size(seg, 2)
           % fprintf('illegal col_ %d', joint_pos(idx, 1));
            col_ = size(seg, 2);
        end
        if col_ < 1
           % fprintf('illegal col_ %d', joint_pos(idx, 1));
            col_ = 1;
        end
       
        %fprintf('row:%d col%d\n', row_, col_);
        if length(find(seg(row_, col_) == seg_idx)) ~= 0
            active = false;
            break;
        end
    end
    if ~active
        return;
    else
        active = false;
        if length(find(seg == seg_idx)) < 100
            return;
        end
        [rows, cols] = find(seg == seg_idx);
        for pos_idx = 1 : length(rows)
            % Make sure col sum
            dis = min(sqrt(sum((skeleton(hand_idx, :) - [cols(pos_idx), rows(pos_idx)]) .^ 2, 2)));
            if dis < threshold
                %fprintf('active superpixel dis : %f\n',dis);
                active = true;
                break;
            end
        end
    end
end