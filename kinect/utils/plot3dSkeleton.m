function plot3dSkeleton(skeletonData, plotColor, plotStyle, plotWidth)
    if nargin < 3
        plotStyle = '-';
        plotWidth = 3;
    end

    index = [4, 21; 21, 1; 12, 9; 9, 21; 5, 21; 5, 8; 1, 18;... % Torso
        1, 14; 18, 20; 14,19;];
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