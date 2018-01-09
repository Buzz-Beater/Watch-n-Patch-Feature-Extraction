% Remaked by Hideshi Tsubota 2012/07/22 @DHRC
%
clear;

% add paths

% Please choice only one path about SVM Library.
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

% combine all kernel descriptors
rgbdfea_joint = [];

load rgbdfea_rgb_gradkdes.mat;
rgbdfea_joint = [rgbdfea_joint; rgbdfea];

%load rgbdfea_rgb_lbpkdes.mat;
%rgbdfea_joint = [rgbdfea_joint; rgbdfea];

load rgbdfea_rgb_rgbkdes.mat;
rgbdfea_joint = [rgbdfea_joint; rgbdfea];

%load rgbdfea_depth_gradkdes.mat;
%rgbdfea_joint = [rgbdfea_joint; rgbdfea];

%load rgbdfea_depth_lbpkdes.mat;
%rgbdfea_joint = [rgbdfea_joint; rgbdfea];

%%BUG
%load rgbdfea_pcloud_spinkdes.mat;
%rgbdfea_joint = [rgbdfea_joint; rgbdfea];
%%End

%load rgbdfea_pcloud_normalkdes.mat;
%rgbdfea_joint = [rgbdfea_joint; rgbdfea];

%load rgbdfea_pcloud_sizekdes.mat;
%rgbdfea_joint = [rgbdfea_joint; rgbdfea];

save -v7.3 rgbdfea_joint rgbdfea_joint rgbdclabel rgbdilabel rgbdvlabel;

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
       load rgbdfea_joint;
       trainfea = rgbdfea_joint(:,ttrainindex);
       clear rgbdfea_joint;
       
       if SVM_TYPE ~= 0
           trainfea = double( trainfea );
           trainfea = sparse( trainfea );%For libsvm and liblinear
       end
       
       [trainfea, minvalue, maxvalue] = scaletrain(trainfea, 'linear'); 
       trainlabel = rgbdclabel(ttrainindex); % take category label

       % classify with liblinear
       if SVM_TYPE == 2
           lc = 0.3;
           option = ['-s 0 -t 0 -b 1 -c ' num2str(lc)];
           model = svmtrain(trainlabel', trainfea', option);
       else
           % Cross Validation 
           %cross_validation_joint;
           %option = ['-s 1 -c ' num2str(bestc)];
           %model = train(trainlabel', trainfea', option);
               
           lc = 10;
           k = (1+log( length(trainhmp(1,:)) )/log(2))*4;
           k = floor(k);
           disp( ['Cross Validation`s Param k is ' num2str(k)] );
           option = ['-s 1 -v ' num2str(k) ' -c ' num2str(lc)];
           cv = train(trainlabel',trainfea',option);
           option = ['-s 1 -c ' num2str(lc)];
           model = train(trainlabel',trainfea',option);
       end
       load rgbdfea_joint;
       testfea = rgbdfea_joint(:,ttestindex);
       clear rgbdfea_joint;
       
       if SVM_TYPE ~= 0
           testfea = double( testfea );
           testfea = sparse( testfea );%For libsvm and liblinear
       end
       
       testfea = scaletest(testfea, 'linear', minvalue, maxvalue);
       testlabel = rgbdclabel(ttestindex); % take category label
       if SVM_TYPE == 2
           [predictlabel, accuracy, decvalues] = svmpredict(testlabel', testfea', model);
       else
           [predictlabel, accuracy, decvalues] = predict(testlabel', testfea', model);
       end
       if SVM_TYPE~= 0
           minvalue = full( minvalue );
           maxvalue = full( maxvalue );
       end
       acc_c(i,1) = mean(predictlabel == testlabel');
       save('./results/joint_acc_c.mat', 'acc_c', 'predictlabel', 'testlabel', 'decvalues');

       % print and save results
       disp(['Accuracy of Liblinear is ' num2str(mean(acc_c))]);
   end
end

