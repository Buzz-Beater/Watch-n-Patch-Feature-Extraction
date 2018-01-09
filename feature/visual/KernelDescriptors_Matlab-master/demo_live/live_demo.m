%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2012/10/17 Written by Hideshi T. @DHRC
% Get RGB and DEPTH image via Kinect and Run KernelDescriptors Object
% Recognition System.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialise
%close all; clear all;

%% Process Program
addpath('../../KinectHandler_Matlab/MexOpenNI');
addpath('../../KinectHandler_Matlab/MexFunc');

%% Load Model Data and process.m
addpath('../demo_rgbd/predictProcess');
%load('modelrgbkdes.mat')
%load('modelgkdes.mat');
%load('modelgkdes_dep.mat');
%load('modelspinkdes.mat');
%load('combinekdes.mat');
USE_MULTI_PARTMODEL = 0;
SVM_PARTMODEL_NUM = 2;

%% Create context with xml file
context = mxNiCreateContext('../../KinectHandler_Matlab/Config/SamplesConfig.xml');

%% Initialise FIGURE
width = 640; height = 480;

%% Initialise Crop Region
CROP_FLAG = 1;
crop_w = 50; crop_h = 100;
center_w = 320; center_h = 240;

%% Initialise Data Structure Field
% depth image
figure, h1 = imagesc(zeros(height,width,'uint16'));
% rgb image
figure, h2 = imagesc(zeros(height,width,3,'uint8'));
%  rgb+depth image
figure, h3 = imagesc(zeros(height,width,3,'uint8')); hold on;
        h4 = imagesc(zeros(height,width,'uint16'));  hold off;
        
%% LOOP
loopcnt = 1;
SELF_CROP_FLAG = 0;
while 1
%for l = 1:1

    tic
    %align Depth onto RGB
    option.adjust_view_point = true;
    % Acquire RGB and Depth image
    mxNiUpdateContext(context, option);
    [rgb, depth] = mxNiImage(context);
    % Update figure 
    set(h1,'CData',depth); 
    set(h2,'CData',rgb); 
    set(h3,'CData',rgb); 
    set(h4,'CData',depth);
    set(h4,'AlphaData',double(depth/50));
    
    % Set crop region
    if CROP_FLAG
        if SELF_CROP_FLAG == 0
            crop_rgb = rgb(center_h-crop_h/2:center_h+crop_h/2, center_w-crop_w/2:center_w+crop_w/2, :);
            crop_depth = depth(center_h-crop_h/2:center_h+crop_h/2, center_w-crop_w/2:center_w+crop_w/2, :);
        end
        
        %Please set your model data...
        %[dec,label,fea, name]=process( 'comrgb', crop_rgb, modelgkdes, modelrgbkdes, combinekdes );
        [dec,label,fea, name]=process( 'rgb', crop_rgb, modelgkdes );
        %[dec,label,fea, name]=processTMPEVA( 'rgb', crop_rgb, modelgkdes );
        %[dec,label,fea, name]=process( 'dep', crop_depth, modelgkdes );
        
        %for multi-part-based model( only predict function )
        if USE_MULTI_PARTMODEL == 1
            for j = 2:SVM_PARTMODEL_NUM
                [dec{j}, label{j}] = processPredictSVM( fea{1}, top_modelrgbkdes, 2);
            end
                
            %combine decvalues
            for j = 2:SVM_PARTMODEL_NUM
                dec{1} =  dec{1} + dec{j};
            end
            [tmp_value, tmp_idx] = max( dec{1} );
            label{1} = tmp_idx;
        end
        
        Xlabel( [ name(label{1}) '  ' num2str(dec{1}(label{1})) ] );
        if SELF_CROP_FLAG == 0
            rectangle( 'Position', [ center_w-crop_w/2, center_h-crop_h/2, crop_w, crop_h ] );
        else
            rectangle( 'Position', [ rect(1), rect(2), rect(3), rect(4) ] );
        end
    end
    
    drawnow;
    disp(['itr=' sprintf('%d',loopcnt) , ' : FPS=' sprintf('%f',1/toc)]);
    loopcnt = loopcnt + 1;
    
    if GetAsyncKeyState(char(27))%esc
        break;
    elseif GetAsyncKeyState(char(83))%s
        [crop_rgb, rect] = imcrop(rgb);
        crop_depth = depth( rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3), : );
        SELF_CROP_FLAG = 1;
        figure, h2 = imagesc(zeros(height,width,3,'uint8'));
   elseif GetAsyncKeyState(char(68))%d
       disp('Delete Crop Image'); 
       SELF_CROP_FLAG = 0;
   end
    
end

%% Delete the context object
mxNiDeleteContext(context);
disp('Release Kinect');