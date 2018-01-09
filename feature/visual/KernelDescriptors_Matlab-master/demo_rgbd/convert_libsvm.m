%function test = convert( modelname, kdes_params, max_imsize, min_imsize, emk_params, G, model,% maxvalue, minvalue, classname )
% Written by Hideshi T. on 2012/07/04

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% below array is needed by this program. So please use this array before running this program.
%%%%%%%%%% For instance
% classname = {'koaramarch_1','koaramarch_2','koaramarch_3','pakuncho_1','pakuncho_2','pakuncho_3'};
%%%%%%%%%% For class
% 8 class
classname = {'bottle', 'can', 'cup', 'koaramarch', 'ornament', 'pack', 'pakuncho' };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Setting
rgbd_depth_gradkdes    = 0;% C++ Supported
rgbd_depthlbpkdes      = 0;% Not yet, C++ Supported
rgbd_pcloud_normalkdes = 0;% C++ Supported
rgbd_pcloud_sizekdes   = 0;% Not yet
rgbd_rgb_gradkdes      = 0;% C++ Supported
rgbd_rgb_lbpkdes       = 0;% Not yet
rgbd_rgb_nrgbkdes      = 0;% C++ Not Supported
rgbd_rgb_rgbkdes       = 1;% C++ Supported
rgbd_joint_category    = 0;% C++ Supported
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here, exec part.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Convert from liblinear matlab model to C++ model');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% RGB-D grad on Depth
if rgbd_depth_gradkdes
disp('Convert rgbd_depth_gradkdes model');

% About kdes
modelgkdes.kdes.max_imsize = 300;
modelgkdes.kdes.min_imsize = 45;
modelgkdes.kdes.grid_space = kdes_params.grid;
modelgkdes.kdes.patch_size = kdes_params.patchsize;
modelgkdes.kdes.low_contrast = 0.8;% Really?
load('gradkdes_dep_params');
modelgkdes.kdes.kdes_params = kdes_params.kdes;

% About emk
modelgkdes.emk.words = rgbdwords;
modelgkdes.emk.pyramid = emk_params.pyramid;
modelgkdes.emk.ktype = emk_params.ktype;
modelgkdes.emk.kparam = emk_params.kparam;
modelgkdes.emk.G = G;

% About svm
modelgkdes.svm.Parameters = model.Parameters;
modelgkdes.svm.nr_class = model.nr_class;
modelgkdes.svm.nr_feature = length(maxvalue);
modelgkdes.svm.bias = -1;
modelgkdes.svm.Label = model.Label;
%modelgkdes.svm.w = model.w;
modelgkdes.svm.minvalue = minvalue;
modelgkdes.svm.maxvalue = maxvalue;
modelgkdes.svm.classname = classname;% Please ready this array before running this program
% Only libsvm params.
modelgkdes.svm.ProbA = model.ProbA;
modelgkdes.svm.ProbB = model.ProbB;
modelgkdes.svm.nSV = model.nSV;
modelgkdes.svm.sv_coef = model.sv_coef;
modelgkdes.svm.SVs = model.SVs;
modelgkdes.svm.rho = model.rho;
modelgkdes.svm.totalSV = model.totalSV;

% For Matlab Program
modelgkdes.matlab.model = model;

% Result
disp('------------------------------------');
disp('Result -----modelgkdes----------');
disp('       -----modelgkdes.kdes-----');
disp(modelgkdes.kdes);
disp('       -----modelgkdes.emk------');
disp(modelgkdes.emk);
disp('       -----modelgkdes.svm------');
disp(modelgkdes.svm);
disp('------------------------------------');

% Save
savefile = 'modelgkdes_dep.mat';
save( savefile, 'modelgkdes' );
disp('Save Done!!');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% RGB-D Spin on Point Cloud
if rgbd_pcloud_normalkdes
disp('Convert rgbd_pcloud_normalkdes model');

% About kdes
modelspinkdes.kdes.max_imsize = 300;
modelspinkdes.kdes.min_imsize = 45;
modelspinkdes.kdes.grid_space = kdes_params.grid;
modelspinkdes.kdes.patch_size = kdes_params.patchsize;
%modelspinkdes.kdes.nromal_window = 5;  % Really?
%modelspinkdes.kdes.normal_threshold = 0.01; % Really?
modelspinkdes.kdes.kdes_params = kdes_params.kdes;

% About emk
modelspinkdes.emk.words = rgbdwords;
modelspinkdes.emk.pyramid = emk_params.pyramid;
modelspinkdes.emk.ktype = emk_params.ktype;
modelspinkdes.emk.kparam = emk_params.kparam;
modelspinkdes.emk.G = G;

% About svm
modelspinkdes.svm.Parameters = model.Parameters;
modelspinkdes.svm.nr_class = model.nr_class;
modelspinkdes.svm.nr_feature = length(maxvalue);
modelspinkdes.svm.bias = -1;
modelspinkdes.svm.Label = model.Label;
%modelspinkdes.svm.w = model.w;
modelspinkdes.svm.minvalue = minvalue;
modelspinkdes.svm.maxvalue = maxvalue;
modelspinkdes.svm.classname = classname;% Please ready this array before running this program
% Only libsvm params.
modelspinkdes.svm.ProbA = model.ProbA;
modelspinkdes.svm.ProbB = model.ProbB;
modelspinkdes.svm.nSV = model.nSV;
modelspinkdes.svm.sv_coef = model.sv_coef;
modelspinkdes.svm.SVs = model.SVs;
modelspinkdes.svm.rho = model.rho;
modelspinkdes.svm.totalSV = model.totalSV;

% For Matlab Program
modelspinkdes.matlab.model = model;

% Result
disp('------------------------------------');
disp('Result -----modelspinkdes----------');
disp('       -----modelspinkdes.kdes-----');
disp(modelspinkdes.kdes);
disp('       -----modelspinkdes.emk------');
disp(modelspinkdes.emk);
disp('       -----modelspinkdes.svm------');
disp(modelspinkdes.svm);
disp('------------------------------------');

% Save
savefile = 'modelspinkdes.mat';
save( savefile, 'modelspinkdes' );
disp('Save Done!!');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% RGB-D grad on RGB-Image
if rgbd_rgb_gradkdes
disp('Convert rgbd_rgb_gradkdes model');

% About kdes
modelgkdes.kdes.max_imsize = 300;
modelgkdes.kdes.min_imsize = 45;
modelgkdes.kdes.grid_space = kdes_params.grid;
modelgkdes.kdes.patch_size = kdes_params.patchsize;
modelgkdes.kdes.low_contrast = 0.8;% Really?
modelgkdes.kdes.kdes_params = kdes_params.kdes;

% About emk
modelgkdes.emk.words = rgbdwords;
modelgkdes.emk.pyramid = emk_params.pyramid;
modelgkdes.emk.ktype = emk_params.ktype;
modelgkdes.emk.kparam = emk_params.kparam;
modelgkdes.emk.G = G;

% About svm
modelgkdes.svm.Parameters = model.Parameters;
modelgkdes.svm.nr_class = model.nr_class;
modelgkdes.svm.nr_feature = length(maxvalue);
modelgkdes.svm.bias = -1;
modelgkdes.svm.Label = model.Label;
%modelgkdes.svm.w = model.w;
modelgkdes.svm.minvalue = minvalue;
modelgkdes.svm.maxvalue = maxvalue;
modelgkdes.svm.classname = classname;% Please ready this array before running this program
% Only libsvm params.
modelgkdes.svm.ProbA = model.ProbA;
modelgkdes.svm.ProbB = model.ProbB;
modelgkdes.svm.nSV = model.nSV;
modelgkdes.svm.sv_coef = model.sv_coef;
modelgkdes.svm.SVs = model.SVs;
modelgkdes.svm.rho = model.rho;
modelgkdes.svm.totalSV = model.totalSV;

% For Matlab Program
modelgkdes.matlab.model = model;

% Result
disp('--------------------------------');
disp('Result -----modelgkdes----------');
disp('       -----modelgkdes.kdes-----');
disp(modelgkdes.kdes);
disp('       -----modelgkdes.emk------');
disp(modelgkdes.emk);
disp('       -----modelgkdes.svm------');
disp(modelgkdes.svm);
disp('--------------------------------');

% Save
savefile = 'modelgkdes.mat';
save( savefile, 'modelgkdes' );
disp('Save Done!!');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% RGB-D normalyed rgb on RGB-Image
if rgbd_rgb_nrgbkdes
disp('Convert rgbd_rgb_nrgbkdes model');

% About kdes
modelrgbkdes.kdes.max_imsize = 300;
modelrgbkdes.kdes.min_imsize = 45;
modelrgbkdes.kdes.grid_space = kdes_params.grid;
modelrgbkdes.kdes.patch_size = kdes_params.patchsize;
modelrgbkdes.kdes.low_contrast = 0;% Really?
modelrgbkdes.kdes.kdes_params = kdes_params.kdes;

% About emk
modelrgbkdes.emk.words = rgbdwords;
modelrgbkdes.emk.pyramid = emk_params.pyramid;
modelrgbkdes.emk.ktype = emk_params.ktype;
modelrgbkdes.emk.kparam = emk_params.kparam;
modelrgbkdes.emk.G = G;

% About svm
modelrgbkdes.svm.Parameters = model.Parameters;
modelrgbkdes.svm.nr_class = model.nr_class;
modelrgbkdes.svm.nr_feature = length(maxvalue);
modelrgbkdes.svm.bias = -1;
modelrgbkdes.svm.Label = model.Label;
%modelrgbkdes.svm.w = model.w;
modelrgbkdes.svm.minvalue = minvalue;
modelrgbkdes.svm.maxvalue = maxvalue;
modelrgbkdes.svm.classname = classname;% Please ready this array before running this program
% Only libsvm params.
modelrgbkdes.svm.ProbA = model.ProbA;
modelrgbkdes.svm.ProbB = model.ProbB;
modelrgbkdes.svm.nSV = model.nSV;
modelrgbkdes.svm.sv_coef = model.sv_coef;
modelrgbkdes.svm.SVs = model.SVs;
modelrgbkdes.svm.rho = model.rho;
modelrgbkdes.svm.totalSV = model.totalSV;

% For Matlab Program
modelrgbkdes.matlab.model = model;

% Result
disp('--------------------------------');
disp('Result -----modelrgbkdes----------');
disp('       -----modelrgbkdes.kdes-----');
disp(modelrgbkdes.kdes);
disp('       -----modelrgbkdes.emk------');
disp(modelrgbkdes.emk);
disp('       -----modelrgbkdes.svm------');
disp(modelrgbkdes.svm);
disp('--------------------------------');

% Save
savefile = 'modelrgbkdes.mat';
save( savefile, 'modelrgbkdes' );
disp('Save Done!!');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% RGB-D rgb on RGB-Image
if rgbd_rgb_rgbkdes
disp('Convert rgbd_rgb_rgbkdes model');

% About kdes
modelrgbkdes.kdes.max_imsize = 300;
modelrgbkdes.kdes.min_imsize = 45;
modelrgbkdes.kdes.grid_space = kdes_params.grid;
modelrgbkdes.kdes.patch_size = kdes_params.patchsize;
modelrgbkdes.kdes.low_contrast = 0;% Really?
modelrgbkdes.kdes.kdes_params = kdes_params.kdes;

% About emk
modelrgbkdes.emk.words = rgbdwords;
modelrgbkdes.emk.pyramid = emk_params.pyramid;
modelrgbkdes.emk.ktype = emk_params.ktype;
modelrgbkdes.emk.kparam = emk_params.kparam;
modelrgbkdes.emk.G = G;

% About svm
modelrgbkdes.svm.Parameters = model.Parameters;
modelrgbkdes.svm.nr_class = model.nr_class;
modelrgbkdes.svm.nr_feature = length(maxvalue);
modelrgbkdes.svm.bias = -1;
modelrgbkdes.svm.Label = model.Label;
%modelrgbkdes.svm.w = model.w;
modelrgbkdes.svm.minvalue = minvalue;
modelrgbkdes.svm.maxvalue = maxvalue;
modelrgbkdes.svm.classname = classname;% Please ready this array before running this program
% Only libsvm params.
modelrgbkdes.svm.ProbA = model.ProbA;
modelrgbkdes.svm.ProbB = model.ProbB;
modelrgbkdes.svm.nSV = model.nSV;
modelrgbkdes.svm.sv_coef = model.sv_coef;
modelrgbkdes.svm.SVs = model.SVs;
modelrgbkdes.svm.rho = model.rho;
modelrgbkdes.svm.totalSV = model.totalSV;

% For Matlab Program
modelrgbkdes.matlab.model = model;

% Result
disp('----------------------------------');
disp('Result -----modelrgbkdes----------');
disp('       -----modelrgbkdes.kdes-----');
disp(modelrgbkdes.kdes);
disp('       -----modelrgbkdes.emk------');
disp(modelrgbkdes.emk);
disp('       -----modelrgbkdes.svm------');
disp(modelrgbkdes.svm);
disp('----------------------------------');

% Save
savefile = 'modelrgbkdes.mat';
save( savefile, 'modelrgbkdes' );
disp('Save Done!!');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% RGB-D Joint Category ( Combine KDES Features )
if rgbd_joint_category
disp('Convert rgbd_joint_category model');

% About kdes
% None

% About emk
% None

% About svm
combinekdes.svm.Parameters = model.Parameters;
combinekdes.svm.nr_class = model.nr_class;
combinekdes.svm.nr_feature = length(maxvalue);
combinekdes.svm.bias = -1;
combinekdes.svm.Label = model.Label;
%combinekdes.svm.w = model.w;
combinekdes.svm.minvalue = minvalue;
combinekdes.svm.maxvalue = maxvalue;
% Only libsvm params.
combinekdes.svm.ProbA = model.ProbA;
combinebkdes.svm.ProbB = model.ProbB;
combinekdes.svm.nSV = model.nSV;
combinekdes.svm.sv_coef = model.sv_coef;
combinekdes.svm.SVs = model.SVs;
combinekdes.svm.rho = model.rho;
combinekdes.svm.totalSV = model.totalSV;

% For Matlab Program
combinekdes.matlab.model = model;

% Result
disp('---------------------------------');
disp('Result -----combinekdes----------');
disp('       -----combinekdes.svm------');
disp(combinekdes.svm);
disp('----------------------------------');

% Save
savefile = 'combinekdes.mat';
save( savefile, 'combinekdes' );
disp('Save Done!!');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%