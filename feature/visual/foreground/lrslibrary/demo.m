%% LRSLibrary: A library of low-rank and sparse tools for background/foreground separation in videos
close, clear, clc;
% restoredefaultpath;

%% First run the setup script
lrs_setup; % or run('C:/GitHub/lrslibrary/lrs_setup')

%% LRS GUI (graphical user interface)
lrs_gui;

%% Load configuration (for demos)
lrs_load_conf;

input_avi = fullfile(lrs_conf.lrs_dir,'dataset','highway.avi');
video = load_video_file(input_avi);
% show_video(video);

M_total = [];
L_total = [];
S_total = [];
O_total = [];
M = []; k = 1; k_max = 50;
nframes = 250; % video.nrFramesTotal;
for i = 1 : nframes
  %disp(['#frame ' num2str(i)]);
  frame = video.frames(i).cdata;
  if(size(frame,3) == 3)
    frame = rgb2gray(frame);
  end
  I = reshape(frame,[],1);
  M(:,k) = I;
  if(k == k_max || i == nframes)
    disp(['#last frame ' num2str(i)]);
    M = im2double(M);
    tic;
    out = run_algorithm('RPCA', 'GoDec', M, []);
    %results = run_algorithm('RPCA', 'IALM', M, []);
    %results = run_algorithm('RPCA', 'FPCP', M, []);
    %results = run_algorithm('LRR', 'FastLADMAP', M, []);
    %results = run_algorithm('NMF', 'NMF-MU', M, []);
    toc
    M_total = [M_total M];
    L_total = [L_total out.L];
    S_total = [S_total out.S];
    O_total = [O_total out.O];
    displog('Displaying results...');
    show_results(M,out.L,out.S,out.O,size(M,2),video.height,video.width);
    M = []; k = 0;
    %break;
  end
  k = k + 1;
end
disp('Finished');

%% Show results
show_results(M_total,L_total,S_total,O_total,size(M_total,2),video.height,video.width);
