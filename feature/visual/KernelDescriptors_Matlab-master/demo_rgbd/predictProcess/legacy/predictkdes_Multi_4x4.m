function [ dec_values, predictlabels ] = predictkdes_Multi_4x4( varargin );
impath = varargin{1};
% Normal
%{
model = varargin{2};
rgbdwords = varargin{3};
maxvalue = varargin{4};
minvalue = varargin{5};
%}

% Use archiver Data
archiver = varargin{2};
load( archiver );
model = archive.model;
rgbdwords = archive.rgbdwords;
maxvalue = archive.maxvalue;
minvalue = archive.minvalue;

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

% Don't edit this param
% initialize the parameters of kdes
kdes_params.grid = 8;   % kdes is extracted every 8 pixels
kdes_params.patchsize = 16;  % patch size
%load('rgbkdes_params');
%kdes_params.kdes = rgbkdes_params;
%load('gradkdes_params');
%kdes_params.kdes = gradkdes_params;
%load('gradkdes_dep_params.mat');
%kdes_params.kdes = gradkdes_dep_params;
load('normalkdes_params');
kdes_params.kdes = normalkdes_params;

% initialize the parameters of data
data_params.datapath = impath;
data_params.tag = 1;
data_params.minsize = 45;  % minimum size of image
data_params.maxsize = 300; % maximum size of image
data_params.savedir = [ '.' ];

I = imread( data_params.datapath );
im_h = size(I,1);
im_w = size(I,2);

% Image Subdivision
w_subsize = im_w/4;
h_subsize = im_h/4;

num_div_x = floor( im_w / w_subsize );
num_div_y = floor( im_h / h_subsize );

if im_w - (num_div_x * w_subsize) > 16
    num_div_x = num_div_x + 1;
end
if im_h - (num_div_y * h_subsize) > 16
    num_div_y = num_div_y + 1;
end

for h = 1:num_div_y
    for w = 1:num_div_x
        
        width_s = (w-1) * w_subsize + 1;
        height_s = (h-1) * h_subsize + 1;
        
        width_e = width_s + w_subsize - 1;
        height_e = height_s + h_subsize - 1;
        if width_e > im_w
            width_e = im_w;
        end
        if height_e > im_h
            height_e = im_h;
        end
        
        disp(w); disp(h);
        disp( width_s ); disp( width_e );
        disp( height_s ); disp( height_e );
        
        %img_div = I( height_s:height_e, width_s:width_e, 1:3 );
        img_div = I( height_s:height_e, width_s:width_e, : );
        str = ['img_div_' num2str(h) '_' num2str(w) '.png'];
        imwrite( img_div, str );
        [ decvalues, predictlabel ] = do_one_kdes( img_div, model, rgbdwords, kdes_params, data_params, maxvalue, minvalue, SVM_TYPE, width_s, height_s );
        for i = 1:model.nr_class
            dec_values(h,w,i) = decvalues(i);
            predictlabels(h,w) = predictlabel;
        end
        
        disp( ['Loop' num2str( h ) ' ' num2str( w ) ] );
        clear img_div;
        
    end
end

function [ decvalues, predictlabel ] = do_one_kdes( I, model, rgbdwords, kdes_params, data_params, maxvalue, minvalue, SVM_TYPE, width_s, height_s )
% KDES
disp('Extracting Kernel Descriptors ...')
switch kdes_params.kdes.type
    case {'gradkdes', 'lbpkdes', 'rgbkdes', 'nrgbkdes'}
        % resize an image
        if data_params.tag
            im_h = size(I,1);
            im_w = size(I,2);
            if max(im_h, im_w) > data_params.maxsize,
                I = imresize(I, data_params.maxsize/max(im_h, im_w), 'bicubic');
             end
             if min(im_h, im_w) < data_params.minsize,
                I = imresize(I, data_params.minsize/min(im_h, im_w), 'bicubic');
             end
        end
              
        % extract dense kernel descriptors over images
        switch kdes_params.kdes.type
            case 'gradkdes'
                feaSet = gradkdes_dense(I, kdes_params);
            case 'lbpkdes'
                feaSet = lbpkdes_dense(I, kdes_params);
            case 'rgbkdes'    
                feaSet = rgbkdes_dense(I, kdes_params);
            case 'nrgbkdes'            
                feaSet = nrgbkdes_dense(I, kdes_params);
            otherwise
                disp('Unknown kernel descriptors');
            end

         case {'gradkdes_dep', 'lbpkdes_dep'}
              % read a depth map
              %I = imread(data_params.datapath{i});
              % normalize depth values to meter
              I = double(I)/1000;
              % extract dense kernel descriptors over depth maps
              switch kdes_params.kdes.type
                   case 'gradkdes_dep'
                         feaSet = gradkdes_dense(I, kdes_params);
                   case 'lbpkdes_dep'
                        feaSet = lbpkdes_dense(I, kdes_params);
                   otherwise
                        disp('Unknown kernel descriptors');
              end

         case {'normalkdes', 'sizekdes'}
            % read a depth map
            %I = imread(data_params.datapath{i});
            I = double(I);
            %topleft = fliplr(load([data_params.datapath{1} '.loc.txt']));
            topleft = load([data_params.datapath(1:end-13) 'loc.txt']);%¡‚¾‚¯
            topleft(1) = topleft(1) + 1; topleft(2) = topleft(2) + 1;
            topleft(1) = topleft(1) + width_s -1; topleft(2) = topleft(2) + height_s -1;
            
            pcloud = depthtocloud(I, topleft);
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
save([data_params.savedir '/tmpkdes'], 'feaSet');
%kdesname = dir( [data_params.savedir '/tmpkdes'] );
%rgbdkdespath = get_kdes_path( data_params.savedir );
rgbdkdespath{1,1} = [data_params.savedir '/tmpkdes'];

% Don't edit this param
basis_params.samplenum = 10;
basis_params.wordnum = 1000;
fea_params.feapath = rgbdkdespath;
% modelrgbkdes.emk.words = rgbdwords;
basis_params.basis = rgbdwords;

disp('Extract image features' );
emk_params.pyramid = [ 1 2 3 ];
emk_params.ktype = 'rbf';
emk_params.kparam = 0.01;
[ rgbdfea, G ] = cksvd_emk_batch(fea_params, basis_params, emk_params );
rgbdfea = single(rgbdfea);

testhmp = rgbdfea;

if SVM_TYPE ~= 0
    testhmp = double( testhmp );
    testhmp = sparse( testhmp );
end

testhmp = scaletest( testhmp, 'linear', minvalue, maxvalue );
testlabel = 1;
if SVM_TYPE == 2
    [ predictlabel, accuracy, decvalues ] = svmpredict( testlabel', testhmp', model );
else
    [ predictlabel, accuracy, decvalues ] = predict( testlabel', testhmp', model );
end

disp( ['Predictlabel is ' num2str(predictlabel) ] );
%End of function%




