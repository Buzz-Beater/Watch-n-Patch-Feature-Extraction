%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ decvalues, predictlabels, features, name ] = process( varargin )
%
% 2012/10/14 Written by Hideshi Tsubota @HOME
%
% [] = process( mode, im, model );
% [] = process( mode, rgbim, depim, rgbmodel, depmodel, combinemodel );
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Global Variant%%
global REALTIME_DEMO;
global IMAGE_READ_FLAG;
global locData;
global deppath;
%% %%%%%%%%%%%%%%%%
mode = 'none';
mode = varargin{1};

kdes_num = 0;

%% Param %%%%%%%%%%
IMAGE_READ_FLAG = 0; %if this param is 1, use imread function.
REALTIME_DEMO = 1;   %Please 1 if you use realtime recognition demo.
if REALTIME_DEMO == 0
    IMAGE_READ_FLAG = 1;
else
    IMAGE_READ_FLAG = 0;
end
%% %%%%%%%%%%%%%%%%

switch mode
    
    case 'rgb'
        impath{1} = varargin{2};
        model{1} = varargin{3};
        kdes_num = 1;
        
    case 'dep'
        impath{1} = varargin{2};
        deppath = impath{1};
        model{1} = varargin{3};
        kdes_num = 1;
        
    case 'comrgb'
        impath{1} = varargin{2};
        for i = 3:nargin
            model{i-2} = varargin{i};
            kdes_num = kdes_num + 1;
        end
        kdes_num = kdes_num - 1;
        
    case 'comdep'
        impath{1} = varargin{2};
        deppath = impath{1};
        for i = 3:nargin
            model{i-2} = varargin{i};
            kdes_num = kdes_num + 1;
        end
        kdes_num = kdes_num - 1;
        
    case 'com'
        impath{1} = varargin{2};
        impath{2} = varargin{3};
        deppath = impath{2};
        for i = 4:nargin
            model{i-3} = varargin{i};
            kdes_num = kdes_num + 1;
        end
        kdes_num = kdes_num - 1;
        
end

SVM_TYPE = 2;
if SVM_TYPE == 0
    disp('Load liblinear-dense-float');
    addpath('../liblinear-1.5-dense-float/matlab');
elseif SVM_TYPE == 1
    disp('Load liblinear-1.91 Original');
    addpath('../liblinear-1.91-original/matlab');
elseif SVM_TYPE == 2
    disp('Load libsvm-3.12 Original');
    addpath('../libsvm-3.12-original/matlab');
end

addpath('../helpfun');
addpath('../kdes');
addpath('../emk');
addpath('../myfun');

for i = 1:kdes_num
   kdesSet{i} =  model{i}.kdes.kdes_params;
end

% Subdivide input image
%[ grid, num_grid ] = subdivision( impath );
[ grid, num_grid ] = slidingWindow( impath );
% How to access -> grid{1,1}{1,1}, grid{1,2}{1,1}...
disp(['The number of Grid Image is ' num2str(num_grid)]);

% Calc the features from All Image Grid
feaSet = calc( grid, num_grid, kdesSet, kdes_num, model );

% Arrange the features
features = feaconjunction( grid, num_grid, feaSet );

% Predict using Support Vector Machine
for i = 1:num_grid
    [ dec, accuracy, label ] = predictSVM( features{i}, model{end}, SVM_TYPE );
    showData( grid, i, dec, label );
    decvalues{i} = dec;
    predictlabels{i} = label;
end
name = model{1}.svm.classname;
disp('All Process done!!');



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ feaSet ] = calc( grid, num_grid, kdesSet, kdes_num, model )
% This is batch function for all grid-size images
% For all images, extract the features
%
% @grid -> grid image structure
% @num_grid -> the number of the grid images
% @kdesSet -> kdes param structures
% @kdes_num -> the number of the kdes
% @model -> this is trained model has emk_params, kdes_params and svm
%
% @feaSet -> extracted features structures
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:num_grid
    %Combine RGB Image and Depth Image.
    if length(grid) == 2
        tmp_fea = extractFeatureAllCombine( 'rgb', grid{1,1}{1,i}, kdesSet, kdes_num, model, num_grid );
        fea{1} = tmp_fea;
        tmp_fea = extractFeatureAllCombine( 'dep', grid{1,2}{1,i}, kdesSet, kdes_num, model, num_grid );
        fea{2} = tmp_fea;
    else
        tmp_fea = extractFeatureAll( grid{1,1}{1,i}, kdesSet, kdes_num, model, num_grid );
        fea{1} = tmp_fea;
    end
    feaSet{i} = fea;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ tmp_fea ] = extractFeatureAll( g, kdesSet, kdes_num, model, num_grid )
% from one image, extract all features
%
% @g -> input image
% @kdesSet -> Same
% @kdes_num -> Same
% @model -> Same
%
% @tmp_fea -> extracted feature
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if kdes_num == 1 
    tmp{1} = extractFeature( g, kdesSet{1}, model{1}, num_grid );
    tmp_fea = tmp;
else
    %Last kdes is combine model.
    for i = 1:kdes_num
        tmp{i} = extractFeature( g, kdesSet{i}, model{i}, num_grid );
    end
    tmp_fea = tmp;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ tmp_fea ] = extractFeatureAllCombine( type, g, kdesSet, kdes_num, model, num_grid )
% from one image, extract rgb and dep features
%
% @type -> it means rgb feature or dep feature
% @g -> Same
% @kdesSet -> Same
% @kdes_num -> Same
% @model -> Same
%
% @tmp_fea -> extracted feature
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch type
    case 'rgb'
        tmp = [];
        for i = 1:kdes_num
    
            if strcmp(kdesSet{i}.type, 'gradkdes') | strcmp(kdesSet{i}.type, 'lbpkdes') | strcmp(kdesSet{i}.type, 'rgbkdes') | strcmp(kdesSet{i}.type, 'nrgbkdes')
                tmp{i} = extractFeature( g, kdesSet{i}, model{i}, num_grid );
            end        
        end
        tmp_fea = tmp;
    case 'dep'
        tmp = [];
        for i = 1:kdes_num
            
            if strcmp(kdesSet{i}.type, 'normalkdes') | strcmp(kdesSet{i}.type, 'sizekdes') | strcmp(kdesSet{i}.type, 'lbpkdes_dep') | strcmp(kdesSet{i}.type, 'gradkdes_dep')
                tmp{i} = extractFeature( g, kdesSet{i}, model{i}, num_grid );
            end
        end
        tmp_fea = tmp;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ fea ] = extractFeature( g, kdes, model, num_grid )
% from one image, extract one feature
%
% Same Params...
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global locData;
global deppath;

kdes_params.kdes = kdes;

switch kdes_params.kdes.type
    case {'gradkdes', 'lbpkdes', 'rgbkdes', 'nrgbkdes'}
        % resize an image
        
        if 1
            im_h = size(g,1);
            im_w = size(g,2);
            %If you don't use this resize func, maybe decrease precision...
            if max(im_h, im_w) > model.kdes.max_imsize,
                g = imresize(g, model.kdes.max_imsize/max(im_h, im_w), 'bicubic');
             end
             if min(im_h, im_w) < model.kdes.min_imsize,
                g = imresize(g, model.kdes.min_imsize/min(im_h, im_w), 'bicubic');
             end
            %
        end
              
        % extract dense kernel descriptors over images
        switch kdes_params.kdes.type
            case 'gradkdes'
                feaSet = gradkdes_dense(g, kdes_params);
            case 'lbpkdes'
                feaSet = lbpkdes_dense(g, kdes_params);
            case 'rgbkdes'    
                feaSet = rgbkdes_dense(g, kdes_params);
            case 'nrgbkdes'            
                feaSet = nrgbkdes_dense(g, kdes_params);
            otherwise
                disp('Unknown kernel descriptors');
            end

         case {'gradkdes_dep', 'lbpkdes_dep'}
              % read a depth map
              %I = imread(data_params.datapath{i});
              % normalize depth values to meter
              g = double(g)/1000;
              % extract dense kernel descriptors over depth maps
              switch kdes_params.kdes.type
                   case 'gradkdes_dep'
                         feaSet = gradkdes_dense(g, kdes_params);
                   case 'lbpkdes_dep'
                        feaSet = lbpkdes_dense(g, kdes_params);
                   otherwise
                        disp('Unknown kernel descriptors');
              end

         case {'normalkdes', 'sizekdes'}
            % read a depth map
            %I = imread(data_params.datapath{i});
            g = double(g);
            
            topleft = fliplr(load([deppath(1:end-13) 'loc.txt']));
            topleft(1) = topleft(1) + 1;%Offset Grabber C++ Program
            topleft(2) = topleft(2) + 1;
            topleft(1) = topleft(1) + locData{num_grid}(2);
            topleft(2) = topleft(2) + locData{num_grid}(1);
            
            pcloud = depthtocloud(g, topleft);
            % normalize depth values to meter
            pcloud = pcloud./1000;
            % extract dense kernel descriptors over point clouds
            switch kdes_params.kdes.type
                 case 'normalkdes'
                      feaSet = normalkdes_dense(pcloud, kdes_params);
                 case 'sizekdes'
                      feaSet = sizekdes_dense(pcloud, kdes_params);
                 otherwise
                      disp('Unknown kernel descriptors');
              end

         otherwise
            disp('Unknown kernel descriptors');
            
end

%Emk Params
basis_params.basis = model.emk.words;
basis_params.G = model.emk.G;

% compute the each images
patchsize = length(feaSet.feaArr);
fea_params.feaSet = feaSet;
fea = cksvd_emk(fea_params, basis_params, model.emk);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ features ] = feaconjunction( grid, num_grid, feaSet );
%
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:num_grid
    %Combine RGB Image and Depth Image.
    if length(grid) == 2
        fea = [];
        gridFea = feaSet{i};
        % About RGB Features
        for r = 1:length(gridFea{1})
           fea = [ fea; gridFea{1}{r} ];
        end
        for d = 1:length(gridFea{2})
            fea = [ fea; gridFea{2}{d} ];
        end
    else
        fea = [];
        gridFea = feaSet{i};
        for j = 1:length(gridFea{1})
            fea = [ fea; gridFea{1}{j} ];
        end
    end
    features{i} = fea;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ decvalues, accuracy, predictlabel ] = predictSVM( fea, model, SVM_TYPE )
%
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testhmp = fea; 
if SVM_TYPE ~= 0
     testhmp = double( testhmp );
     testhmp = sparse( testhmp );
end

testhmp = scaletest( testhmp, 'linear', model.svm.minvalue, model.svm.maxvalue );
testlabel = 1;%this is no meaning

if SVM_TYPE == 2
    [ predictlabel, accuracy, decvalues ] = svmpredict( testlabel', testhmp', model.matlab.model );
else
    [ predictlabel, accuracy, decvalues ] = predict( testlabel', testhmp', model.matlab.model );
end 



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showData( grid, index, decvalue, label )
% 
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REALTIME_DEMO;

pause on;
if REALTIME_DEMO == 0
    imshow( grid{1,1}{1,index} );
end
disp( [ 'Label is ' num2str(label) ] );

fprintf( 'Probability->\n' );
for i = 1:length(decvalue)
   fprintf( '%d->%3.1f  ', i, decvalue(i)*100 ); 
end
if REALTIME_DEMO == 0
    disp( [ 'Probability : ' num2str(decvalue(1,index,:)) ] );
    pause;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ grid, num_grid ] = subdivision( impath );
%Image Subdivision
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global IMAGE_READ_FLAG;
global locData;
global deppath;

for i = 1:length(impath)
    
    if IMAGE_READ_FLAG
        I = imread( impath{i} );
    else
        I = impath{i};
    end
    
    im_h = size(I,1);
    im_w = size(I,2);
    
    %subsize_x = im_w;
    %subsize_y = im_h;
    subsize_x = 64;
    subsize_y = 64;
    
    div_x = floor( im_w / subsize_x );
    div_y = floor( im_h / subsize_y );
    if im_w - (div_x * subsize_x) > 16
        div_x = div_x + 1;
    end
    if im_h - (div_y * subsize_y) > 16
        div_y = div_y + 1;
    end
    
    count = 1;
    for h = 1:div_y
        for w = 1:div_x
        
            width_s = (w-1) * subsize_x + 1;
            height_s = (h-1) * subsize_y + 1;
        
            width_e = width_s + subsize_x - 1;
            height_e = height_s + subsize_y - 1;
            if width_e > im_w
                width_e = im_w;
            end
            if height_e > im_h
                height_e = im_h;
            end
                
            %For pcloud features
            tmp_loc(count,1) = height_s - 1 ; tmp_loc(count,2) = width_s - 1;
           
            tmp_grid{count} = I( height_s:height_e, width_s:width_e, : );
            %If you want to save grid image, please use this code.
            %str = ['grid_' num2str(i) '_' num2str(h) '_' num2str(w) '.png'];
            %imwrite( tmp_grid{count}, str );
            count = count + 1;
        end
    end
    
    grid{i} = tmp_grid;
    locData{i} = tmp_loc;
    num_grid = length( grid{i} );
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ grid, num_grid ] = slidingWindow( impath );
%Sliding Windows Method
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global IMAGE_READ_FLAG;
global locData;
global deppath;

for i = 1:length(impath)
    
    if IMAGE_READ_FLAG
        I = imread( impath{i} );
    else
        I = impath{i};
    end
    
    im_h = size(I,1);
    im_w = size(I,2);
    
    %Don't use at slidewindow.
    %{
    if max(im_h, im_w) > 300,
        I = imresize(I, 300/max(im_h, im_w), 'bicubic');
        im_h = size(I,1);
        im_w = size(I,2);
    end
    if min(im_h, im_w) < 45,
        I = imresize(I, 45/min(im_h, im_w), 'bicubic');
        im_h = size(I,1);
        im_w = size(I,2);
    end
    %}
    
    subsize_x = im_w/2.0;
    subsize_y = im_h/2.0;
    %subsize_x = im_w;;
    %subsize_y = im_h;
    step = subsize_x;
    
    count = 1;
    for h = 1:step:im_h
        height_s = h;
        height_e = height_s + subsize_y - 1;
        
        if height_e > im_h, break, end;
                    
        for w =1:step:im_w
           width_s = w;
           width_e = width_s + subsize_x - 1;
           
           if width_e > im_w, break, end;
           
           %For pcloud features
           tmp_loc(count,1) = height_s - 1 ; tmp_loc(count,2) = width_s - 1;
           
           tmp_grid{count} = I( height_s:height_e, width_s:width_e, : );
           %If you want to save grid image, please use this code.
           str = ['grid_' num2str(i) '_' num2str(h) '_' num2str(w) '.png'];
           imwrite( tmp_grid{count}, str );
           count = count + 1;
        end
    end
    
    grid{i} = tmp_grid;
    locData{i} = tmp_loc;
    num_grid = length( grid{i} );
end