%function predictkdes( impath )
impath = '../images/rgbdsubset/bottle/bottle_1/bottle_1_1_10_crop.png'
%impath = '~/Desktop/divimg_bottle1/img_1_1_1.png';
%impath = '~/Desktop/divimg_can1div/img_45_1_1.png';


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
load('rgbkdes_params');
kdes_params.kdes = rgbkdes_params;

% initialize the parameters of data
data_params.datapath = impath;
data_params.tag = 1;
data_params.minsize = 45;  % minimum size of image
data_params.maxsize = 300; % maximum size of image
data_params.savedir = [ '.' ];

% KDES
disp('Extracting Kernel Descriptors ...')
switch kdes_params.kdes.type
    case {'gradkdes', 'lbpkdes', 'rgbkdes', 'nrgbkdes'}
    % read an image
    I = imread(data_params.datapath);
        

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
              I = imread(data_params.datapath{i});
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
            I = imread(data_params.datapath{i});
            I = double(I);
            topleft = fliplr(load([data_params.datapath{i}(1:end-13) 'loc.txt']));
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
if SVM_TYPE == 2
    [ predictlabel, accuracy, decvalues ] = svmpredict( testlabel', testhmp', model );
else
    [ predictlabel, accuracy, decvalues ] = predict( testlabel', testhmp', model );
end

disp( ['Predictlabel is ' num2str(predictlabel) ] );




