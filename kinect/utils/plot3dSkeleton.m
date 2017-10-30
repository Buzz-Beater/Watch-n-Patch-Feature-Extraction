function plot3dSkeleton(skeletonData, plotColor, plotStyle, plotWidth)
    if nargin < 3
        plotStyle = '-';
        plotWidth = 3;
    end

    index = [
                24, 11; 24, 11; 11, 10; 10, 9; 9, 8; 8, 20;... % right arm
                21, 7; 22, 7; 7, 6; 6, 5; 5, 4; 4, 20;... % left arm
                3, 2; 2, 20;... % head
                20, 1; 1, 0;... % torso
                19, 14; 14, 17; 17, 16; 16, 0;... % right leg
                15, 18; 18, 13; 13, 12; 12, 0;... % left leg
            ] + 1;
    disp('plotting error alignement');
        %{
        ... % Left arm
        8, 9; 9, 10; 10, 11;... % Right arm
        12, 13; 13, 14; 14, 15;... % Left leg
        16, 17; 17, 18; 18, 19;]... % Right leg
        + 1; % C index to matlab index
        %}
    
    for i = 1:size(index, 1)
        plot3(skeletonData(index(i, :), 1), skeletonData(index(i, :), 2), skeletonData(index(i, :), 3), ...
            'Color', plotColor, 'LineWidth', plotWidth, 'lineStyle', plotStyle);
    end
    hold on;
    plot3(skeletonData(9, 1), skeletonData(9, 2), skeletonData(9, 3), '.','Color','y','markers',12);
    text(skeletonData(9,1),skeletonData(9, 2), skeletonData(9, 3), ['(' num2str(skeletonData(9, 1)),',' num2str(skeletonData(9, 2)) , ',', num2str(skeletonData(9, 3)),')']);
    
    
%     campos([0, 0, 0]);
%     camup([0, 1, 0]);
%     axis equal;
end