% remaked by Hideshi Tsubota on 2012/07/19 @DHRC
% at scaletest and scaletrain, use linear option
%
% written by Liefeng Bo on 03/27/2012 in University of Washington

clear;

% add paths
% Please choice only one path about SVM Library.
SVM_TYPE = 1;
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

% compute the paths of images
imdir = '../images/rgbdsubset/';
%imdir = '../images/rgbdsubset_right/';
imsubdir = dir_bo(imdir);
impath = [];
rgbdclabel = [];
rgbdilabel = [];
rgbdvlabel = [];
subsample = 5;
disp(['subsample is ' num2str(subsample)]);
label_num = 0;
for i = 1:length(imsubdir)
    [rgbdilabel_tmp, impath_tmp] = get_im_label([imdir imsubdir(i).name '/'], '_depthcrop.png');
    for j = 1:length(impath_tmp)
        ind = find(impath_tmp{j} == '_');
        rgbdvlabel_tmp(1,j) = str2num(impath_tmp{j}(ind(end-2)+1));
    end

    it = 0;
    for j = 1:subsample:length(impath_tmp)
        it = it + 1;
        impath_tmp_sub{it} = impath_tmp{j};
    end
    impath = [impath impath_tmp_sub];
    rgbdclabel = [rgbdclabel i*ones(1,length(impath_tmp_sub))];
    rgbdilabel = [rgbdilabel rgbdilabel_tmp(1:subsample:end)+label_num];
    rgbdvlabel = [rgbdvlabel rgbdvlabel_tmp(1:subsample:end)];
    label_num = label_num + length(unique(rgbdilabel_tmp));
    clear impath_tmp_sub rgbdvlabel_tmp;
end

% initialize the parameters of kdes
kdes_params.grid = 8;   % kdes is extracted every 8 pixels
kdes_params.patchsize = 40;  % patch size
load('normalkdes_params');
kdes_params.kdes = normalkdes_params;

% initialize the parameters of data
data_params.datapath = impath;
data_params.tag = 1;
data_params.minsize = 45;  % minimum size of image
data_params.maxsize = 300; % maximum size of image
data_params.savedir = ['../kdesfeatures/rgbd' 'normalkdes'];

% extract kernel descriptors
mkdir_bo(data_params.savedir);
rgbdkdespath = get_kdes_path(data_params.savedir);
if ~length(rgbdkdespath)
   gen_kdes_batch(data_params, kdes_params);
   rgbdkdespath = get_kdes_path(data_params.savedir);
end

featag = 1;
if featag
   % learn visual words using K-means
   % initialize the parameters of basis vectors
   basis_params.samplenum = 10; % maximum sample number per image scale
   basis_params.wordnum = 1000; % number of visual words
   fea_params.feapath = rgbdkdespath;
   rgbdwords = visualwords(fea_params, basis_params);
   basis_params.basis = rgbdwords;

   % constrained kernel SVD coding
   disp('Extract image features ... ...');
   % initialize the params of emk
   emk_params.pyramid = [1 2 3];
   emk_params.ktype = 'rbf';
   emk_params.kparam = 0.1;
   fea_params.feapath = rgbdkdespath;
   [rgbdfea, G] = cksvd_emk_batch(fea_params, basis_params, emk_params);
   rgbdfea = single(rgbdfea);
   save -v7.3 rgbdfea_pcloud_normalkdes rgbdfea rgbdclabel rgbdilabel rgbdvlabel rgbdwords G;
else
   disp('Loading bag of words data insted of calc');
   load rgbdfea_pcloud_normalkdes;
end

category = 1;
if category
   trail = 1;
   for i = 1:trail
       % generate training and test samples
       ttrainindex = [];
       ttestindex = [];
       labelnum = unique(rgbdclabel);
       for j = 1:length(labelnum)
           trainindex = find(rgbdclabel == labelnum(j));
           rgbdilabel_unique = unique(rgbdilabel(trainindex));
           perm = randperm(length(rgbdilabel_unique));
           subindex = find(rgbdilabel(trainindex) == rgbdilabel_unique(perm(1)));
           testindex = trainindex(subindex);
           %trainindex(subindex) = [];%debug
           ttrainindex = [ttrainindex trainindex];
           ttestindex = [ttestindex testindex];
       end
       load rgbdfea_pcloud_normalkdes;
       trainhmp = rgbdfea(:,ttrainindex);
       clear rgbdfea;
       
       if SVM_TYPE ~= 0
           trainhmp = double( trainhmp );
           trainhmp = sparse( trainhmp );%For libsvm and liblinear
       end
       
       [trainhmp, minvalue, maxvalue] = scaletrain(trainhmp, 'linear');
       trainlabel = rgbdclabel(ttrainindex); % take category label

       % classify with liblinear
       if SVM_TYPE == 2
           lc = 0.3;
           option = ['-s 0 -t 0 -b 1 -c ' num2str(lc)];
           model = svmtrain(trainlabel', trainhmp', option);
       else
           % Cross Validation 
           %cross_validation;
           %option = ['-s 1 -c ' num2str(bestc)];
           %model = train(trainlabel', trainhmp', option);
               
           lc = 0.3;
           k = (1+log( length(trainhmp(1,:)) )/log(2))*4;
           k = floor(k);
           %disp( ['Cross Validation`s Param k is ' num2str(k)] );
           %option = ['-s 1 -v ' num2str(k) ' -c ' num2str(lc)];
           %cv = train(trainlabel',trainhmp',option);
           option = ['-s 1 -c ' num2str(lc)];
           model = train(trainlabel',trainhmp',option);
       end
       
       load rgbdfea_pcloud_normalkdes;
       testhmp = rgbdfea(:,ttestindex);
       clear rgbdfea;
       
       if SVM_TYPE ~= 0
           testhmp = double( testhmp );
           testhmp = sparse( testhmp );%For libsvm and liblinear
       end
       
       testhmp = scaletest(testhmp, 'linear', minvalue, maxvalue);
       testlabel = rgbdclabel(ttestindex); % take category label
       if SVM_TYPE == 2
           [predictlabel, accuracy, decvalues] = svmpredict(testlabel', testhmp', model);
       else
           [predictlabel, accuracy, decvalues] = predict(testlabel', testhmp', model);
       end
       acc_c(i,1) = mean(predictlabel == testlabel');
       save('./results/pcloud_normalkdes_acc_c.mat', 'acc_c', 'predictlabel', 'testlabel', 'decvalues');

       % print and save results
       disp(['Accuracy of Liblinear is ' num2str(mean(acc_c))]);
   end
end

instance = 0;
if instance

   % generate training and test indexes
   indextrain = 1:length(rgbdilabel);
   indextest = find(rgbdvlabel == 1);
   %indextrain(indextest) = [];//debug

   % generate training and test samples
   load rgbdfea_pcloud_normalkdes;
   trainhmp = rgbdfea(:, indextrain);
   trainlabel = rgbdilabel(:, indextrain);
   clear rgbdfea;
   [trainhmp, minvalue, maxvalue] = scaletrain(trainhmp, 'linear');

   disp('Performing liblinear ... ...');
   lc = 10;
   % classify with liblinear
   option = ['-s 1 -c ' num2str(lc)];
   model = train(trainlabel',trainhmp',option);
   load rgbdfea_pcloud_normalkdes;
   testhmp = rgbdfea(:, indextest);
   testlabel = rgbdilabel(:, indextest);
   clear rgbdfea;
   testhmp = scaletest(testhmp, 'linear', minvalue, maxvalue);
   [predictlabel, accuracy, decvalues] = predict(testlabel', testhmp', model);
   acc_i = mean(predictlabel == testlabel');
   save('./results/pcloud_normalkdes_acc_i.mat', 'acc_i', 'predictlabel', 'testlabel');

   % print and save classification accuracy
   disp(['Accuracy of Liblinear is ' num2str(mean(acc_i))]);
end

