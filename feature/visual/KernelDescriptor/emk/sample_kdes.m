% sample kdes for clustering
% mainly written when Liefeng Bo was in toyota technological institute at Chicago (TTI-C), working with Cristian Sminchisescu 
% modified by Baoxiong Jia in UCLA, 2018

function kdesset = sample_kdes(fea_params, samplenum)
    kdespath = fea_params.feapath;
    load(kdespath{1});
    dim = size(feaSet.feaArr{1},1);
    scalesize = length(feaSet.feaArr);

    % initialize the parameters
    samsize = length(kdespath)*samplenum*scalesize;
    kdesset = zeros(dim,samsize);
    it = 0;
    count = 0;
    
    if strcmp(fea_params.scene_type, 'kitchen')
        skip = 2;
    else
        skip = 1;
    end
    
    for i = 1: skip: length(kdespath)
        load(kdespath{i});
        for ss = 1:scalesize
            it = it + 1;
            kdes = double(feaSet.feaArr{ss});
            kdesnum = size(kdes,2);
            num = min(kdesnum,samplenum);
            perm = randsample(kdesnum, num);
            kdesset(:,count+(1:num)) = kdes(:,perm);
            count = count + num;
            if mod(it,10) == 1
               disp(['Current Iteration is: ' num2str(it)]);
            end
        end
    end
kdesset(:,count+1:end) = [];


