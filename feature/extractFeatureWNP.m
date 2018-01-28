addpath('skeleton');
addpath('visual');
addpath(genpath('visual/superpixel'));
addpath(genpath('visual/superpixel/utils'));
addpath(genpath('visual/foreground'));
run('visual/foreground/lrslibrary/lrs_setup');
addpath('visual/foreground/STOC-RPCA');
addpath('visual/superpixel')

%traverse_dir('../Dataset', 'foreground');
%traverse_dir('../Dataset', 'skeleton');
traverse_dir('../Dataset', 'superpixel');