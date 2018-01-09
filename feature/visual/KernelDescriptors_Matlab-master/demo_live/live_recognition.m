%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2012/10/24 Written by Hideshi T. @DHRC
%% Objects Recognition Program.
%% Segmentation( plane fitting, clustering ), KernelDescriptors
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%close all; clear all;
%% Load Path
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

%% Recognition Limit in order to prevent from increasing calc cost
recognition_limit = 2;

%% Create context with xml file
context = mxNiCreateContext('../../KinectHandler_Matlab/Config/SamplesConfig.xml');

%% Initialise FIGURE
width = 640; height = 480;
% depth image
figure, h1 = imagesc(zeros(height,width,'uint16'));
% rgb image
figure, h2 = imagesc(zeros(height,width,3,'uint8'));
% rgb+depth image
figure, h3 = imagesc(zeros(height,width,3,'uint8')); hold on;
        h4 = imagesc(zeros(height,width,'uint16'));  hold off;
% XYZ values 
figure, h5 = mesh(zeros(height,width,'double'),zeros(height,width,'double'),zeros(height,width,'double'));
           axis([-800 800 -600 600 -10000 -1 ]); view(180,90);
           xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]');
           title('XYZ ÅiThe world coordinate systemÅj');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main LOOP
k = 1;
%for k=1:100
while 1
    
    tic
    %align Depth onto RGB
    option.adjust_view_point = true;
    % Acquire RGB and Depth image    
    mxNiUpdateContext(context, option);
    [rgb, depth] = mxNiImage(context);
    % convert uvZ[pix,pix,mm] to XYZ[mm,mm,mm]
    real_XYZ = mxNiConvertProjectiveToRealWorld(context, depth); 
    %convert XYZ[mm,mm,mm] to uvZ[pix,pix,mm]
    projective_uvZ = mxNiConvertRealWorldToProjective(context, real_XYZ);  
    
    %Segmentation
    XYZ=double(real_XYZ);
    clear bbox bbox3d bbox2d;
    X=XYZ(:,:,1); Y=XYZ(:,:,2); Z=XYZ(:,:,3);
   
    % Downsampling 
    subsample = 3;
    X=downsample(X,subsample); X=downsample(X',subsample); X=X';
    Y=downsample(Y,subsample); Y=downsample(Y',subsample); Y=Y';
    Z=downsample(Z,subsample); Z=downsample(Z',subsample); Z=Z';
    
    %Plane Fitting and Clustering
    bbox = clustering(X, Y, Z); bbox=bbox(1:3,:);
    
    num = -1;
    %Calc kdes features and predict
    if length(bbox) ~= 0
        
        %Calc bunding box pos on 2D-image
        [bbox3d, num] = reshapebbox(bbox);
        bbox3d = single(bbox3d);
        bbox2d = mxNiConvertRealWorldToProjective(context, bbox3d); 
    
        rgb_calc = rgb;
        labelstr = [];
        %call process.m in order to recognition objects
        for i = 1:2:num
                   
            %extract image region
            x = bbox2d(1,i,1); y = bbox2d(1,i+1,2);
            nx = bbox2d(1,i+1,1); ny = bbox2d(1,i,2);
            if (x < 1 | x > width) | ( nx < 1 | nx > width ) | ( y < 1 | y > height ) | ( ny < 1 | ny > height )
                continue;
            end
            
            %process.m
            crop_rgb = rgb_calc( y:ny, x:nx, : ); crop_depth = depth( y:ny, x:nx, : );
            [dec, label, fea, name]=process( 'rgb', crop_rgb, modelgkdes );
            
            %for multi-part-based model( only predict function )
            if USE_MULTI_PARTMODEL == 1
                for j = 2:SVM_PARTMODEL_NUM
                    [dec{j}, label{j}] = processPredictSVM( fea{1}, full_modelrgbkdes, 2);
                end
                
                %combine decvalues
                for j = 2:SVM_PARTMODEL_NUM
                   dec{1} =  dec{1} + dec{j};
                end
                [tmp_value, tmp_idx] = max( dec{1} );
                label{1} = tmp_idx;
            end
            
            %show results
            labelstr = [ labelstr name(label{1}) ' ' num2str(dec{1}(label{1})) ' ' ];
            h_rec(i) = rectangle( 'Position', [ x, y, nx-x, ny-y ], 'edgecolor', 'g' );
            if recognition_limit <= i
                break;
            end
                        
        end
        
        Xlabel( labelstr );
    else
        Xlabel( 'No Object' ); 
    end
    
    %update Figure
    set(h1, 'CData', depth);
    set(h2, 'CData', rgb);
    set(h3, 'CData', rgb);
    set(h4, 'CData', depth);
    set(h4, 'AlphaData', double(depth/50));
    % update Figue of XYZ
    tmp = real_XYZ(:);
    tmp(find(real_XYZ==0)) = NaN;
    tmp = reshape(tmp,[height width 3]);
    set(h5,'XData',-tmp(:,:,1));
    set(h5,'YData',-tmp(:,:,2));
    set(h5,'ZData',-tmp(:,:,3));
    drawnow;
    
    %Release
    for i=1:2:num
        delete(h_rec(i));
        if recognition_limit <= i
            break;
        end
    end
    
    %show FPS and frame No.
    disp(['itr=' sprintf('%d',k) , ' : FPS=' sprintf('%f',1/toc)]);
    k = k + 1;
    
    %wait key in order to stop this program
    if GetAsyncKeyState(char(27))
        break;
    end
    
end
%% Main LOOP
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Delete the context object
mxNiDeleteContext(context);
disp('Release Kinect');