function [ dec_values, predictlabels ] = predictkdes_Multi_Combine( varargin )
impath = varargin{1};
deppath = varargin{2};
%{
model = varargin{3};
maxvalue = varargin{4};
minvalue = varargin{5};
rgbwords = varargin{6};
depwords = varargin{7};
%}

% Use archiver Data
rgbarchiver = varargin{3};
load( rgbarchiver );
%model = archive.model;
rgbwords = archive.rgbdwords;
%maxvalue = archive.maxvalue;
%minvalue = archive.minvalue;
clear archive;

deparchiver = varargin{4};
load( deparchiver );
%model = archive.model;
depwords = archive.rgbdwords;
%maxvalue = archive.maxvalue;
%minvalue = archive.minvalue;
clear archive;

combinearchiver = varargin{5};
load( combinearchiver );
model = archive.model;
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

num_combinekdes = 2;
%set_kdes{1} = 'rgbdkdes_params';
%set_kdes{2} = 'gradkdes_dep_params';

rgbkdes_params.grid = 8;   % kdes is extracted every 8 pixels
rgbkdes_params.patchsize = 16;  % patch size
load( 'rgbkdes_params' );
rgbkdes_params.kdes = rgbkdes_params;
% initialize the parameters of data
rgbdata_params.datapath = impath;
rgbdata_params.tag = 1;
rgbdata_params.minsize = 45;  % minimum size of image
rgbdata_params.maxsize = 300; % maximum size of image
rgbdata_params.savedir = [ '.' ];


deprgbkdes_params.grid = 8;   % kdes is extracted every 8 pixels
deprgbkdes_params.patchsize = 16;  % patch size
load( 'normalkdes_params' );
depkdes_params.kdes = normalkdes_params;
% initialize the parameters of data
depdata_params.datapath = deppath;
depdata_params.tag = 1;
depdata_params.minsize = 45;  % minimum size of image
depdata_params.maxsize = 300; % maximum size of image
depdata_params.savedir = [ '.' ];

% Image Subdivision
I = imread( rgbdata_params.datapath );
II =imread( depdata_params.datapath );
im_h = size(I,1);
im_w = size(I,2);

% Image Subdivision
%subsize = 32;
w_subsize = im_w/2;
h_subsize = im_h/2;

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
        
        img_div = I( height_s:height_e, width_s:width_e, 1:3 );
        dep_div = II( height_s:height_e, width_s:width_e, : );
        str = ['img_div_' num2str(h) '_' num2str(w) '.png'];
        depstr = ['dep_div_' num2str(h) '_' num2str(w) '.png'];
        imwrite( img_div, str );
        imwrite( dep_div, depstr );
            
        rgbfea = calc_kdes( img_div, rgbwords, rgbkdes_params, rgbdata_params );
        depfea = calc_kdes( dep_div, depwords, depkdes_params, depdata_params, width_s, height_s );
            
        [ decvalues, predictlabel ] = predictcombine( rgbfea, depfea, model, maxvalue, minvalue, SVM_TYPE );
        for i = 1:model.nr_class
            dec_values(h,w,i) = decvalues(i);
            predictlabels(h,w) = predictlabel;
        end
        
        disp( ['Loop' num2str( h ) ' ' num2str( w ) ] );
        clear img_div;
        clear dep_div;
    end
end

function [ rgbdfea ] = calc_kdes( I, words, kdes_params, data_params, width_s, height_s )
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
save([data_params.savedir '/tmpkdes' ], 'feaSet');
%kdesname = dir( [data_params.savedir '/tmpkdes'] );
%rgbdkdespath = get_kdes_path( data_params.savedir );
rgbdkdespath{1,1} = [data_params.savedir '/tmpkdes'];

% Don't edit this param
basis_params.samplenum = 10;
basis_params.wordnum = 1000;
fea_params.feapath = rgbdkdespath;
% modelrgbkdes.emk.words = rgbdwords;
basis_params.basis = words;

disp('Extract image features' );
emk_params.pyramid = [ 1 2 3 ];
emk_params.ktype = 'rbf';
emk_params.kparam = 0.01;
[ rgbdfea, G ] = cksvd_emk_batch(fea_params, basis_params, emk_params );
rgbdfea = single(rgbdfea);

function [ decvalues, predictlabel ] = predictcombine( rgbfea, depfea, model, maxvalue, minvalue, SVM_TYPE )

testhmp = [];
testhmp = [ testhmp; rgbfea ];
testhmp = [ testhmp; depfea ];

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




