% Segmentation Program
% Get RGB and DEPTH image, then convert uvZ[pix,pix,mm] value to XYZ[mm,mm,mm]

%close all; clear all;
addpath('../../KinectHandler_Matlab/MexOpenNI');
addpath('../../KinectHandler_Matlab/MexFunc');
%% Create context with xml file
context = mxNiCreateContext('../../KinectHandler_Matlab/Config/SamplesConfig.xml');

%%  Initialise FIGURE
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

%% LOOP
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
   
    subsample = 4;
    X=downsample(X,subsample); X=downsample(X',subsample); X=X';
    Y=downsample(Y,subsample); Y=downsample(Y',subsample); Y=Y';
    Z=downsample(Z,subsample); Z=downsample(Z',subsample); Z=Z';
    
    bbox = clustering(X, Y, Z); bbox=bbox(1:3,:);
    if length(bbox) ~= 0
        
        [bbox3d, num] = reshapebbox(bbox);
        bbox3d = single(bbox3d);
        bbox2d = mxNiConvertRealWorldToProjective(context, bbox3d); 
    
        for i = 1:2:num
            %rec(ceil(i/2))=rectangle( 'Position', [ bbox2d(1,i,1), bbox2d(1,i+1,2), bbox2d(1,i+1,1)-bbox2d(1,i,1), bbox2d(1,i,2)-bbox2d(1,i+1,2) ] ); 
            %set(rec(ceil(i/2)),'EdgeColor','g');
            %refreshdata;
       
            x = bbox2d(1,i,1); y = bbox2d(1,i+1,2);
            nx = bbox2d(1,i+1,1); ny = bbox2d(1,i,2);
            rgb(y:ny,x:nx,:)=255;
        end
    end
    
    % update Figure
    set(h1, 'CData', depth);
    set(h2, 'CData', rgb);
    set(h3,'CData',rgb);
    set(h4,'CData',depth);
    set(h4,'AlphaData',double(depth/50));
    % update Figue of XYZ
    tmp = real_XYZ(:);
    tmp(find(real_XYZ==0)) = NaN;
    tmp = reshape(tmp,[height width 3]);
    set(h5,'XData',-tmp(:,:,1));
    set(h5,'YData',-tmp(:,:,2));
    set(h5,'ZData',-tmp(:,:,3));
    drawnow;
    
    % FPS
    disp(['itr=' sprintf('%d',k) , ' : FPS=' sprintf('%f',1/toc)]);
    k = k + 1;
    if GetAsyncKeyState(char(27))
        break;
    end
end

%% Delete the context object 
mxNiDeleteContext(context);
disp('Release Kinect');