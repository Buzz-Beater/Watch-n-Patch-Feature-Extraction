% 2012/09/10
% Written by Hideshi Tsubota@DHRC
% Plot function about distance from hyper plane
%

hold all;

%All Plot
if 1
    for i = 1:length( ttestindex )
        plot(disHyperplane(i,:),'DisplayName','disHyperplane(i,:)','YDataSource','disHyperplane(i,:)');figure(gcf)
    end
end

%Per hyper plane
if 0
    for i = 1:length( ttestindex )
        plot(disHyperplane(i,:),'DisplayName','disHyperplane(i,:)','YDataSource','disHyperplane(i,:)');figure(gcf)
    end
end