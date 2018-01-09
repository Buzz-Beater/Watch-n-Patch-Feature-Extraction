%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2012/10/18 Written by Hideshi T. @DHRC
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ graph ] = probMap( decvalues, modelnum, width, height, step, subx, suby )
%
% decvalues -> libsvm output
% modelnum -> svm class num
% width -> image size
% height -> image size
% step -> sliding window method's step
% width -> subwindow width
% height -> subwindow height
%
% graph -> output, probability map
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for m = 1:modelnum
    tmp_graph = combine_prob( decvalues, m, width, height, step, subx, suby );
    graph{m} = tmp_graph;
    showData( graph{m} );
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ graph ] = combine_prob( decvalues, modelidx, width, height, step, subx, suby )
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph = zeros(height,width);
count = 1;

for h = 1:step:height
     
    h_s = h;
    h_e = h_s + suby - 1;
    if h_e > height, break, end;
    
    for w = 1:step:width
        
        w_s = w;
        w_e = w_s + subx -1;
        if w_e > width, break, end;
        
        % Add Method
        %graph(h_s:h_e,w_s:w_e) = graph(h_s:h_e,w_s:w_e) + decvalues{count}(modelidx);
        % Max Method
        graph(h_s:h_e,w_s:w_e) = max( graph(h_s:h_e,w_s:w_e), decvalues{count}(modelidx) );
                
        %disp(count);
        count = count + 1;
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showData( g )
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
imagesc( g );
colorbar;