% generate basis vectors/visual words
% mainly written when Lieeng Bo was in toyota technological institute at Chicago (TTI-C), working with Cristian Sminchisesc
% modified Baoxiong Jia in UCLA, 2018

function words = visualwords(fea_params, basis_params)  

    disp('Sample kernel descriptors  ... ...');
    kdessample = sample_kdes(fea_params, basis_params.samplenum);

    disp('Perform K-Means ... ...');
    % kmeans
    words = kmeans_bo(kdessample', basis_params.wordnum, basis_params.num_iter);
    words = words';


