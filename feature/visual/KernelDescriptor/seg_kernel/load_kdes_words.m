
function kdes_words=load_kdes_words( kdesname, kparam, scene_type, word_type )
%
% function kdes_words=load_kdes_words( kdesname, kparam )
%
%

kdes_words.ktype='rbf'; 
kdes_words.kparam=kparam;

load(['../kdes/' kdesname '_params.mat'],[kdesname '_params']);
eval(['kdes_words.params=' kdesname '_params;']);

kdes_words.grid_space=2;

% modify this line to the correct visual words you are using, to change word_type, see config.m in this directory

load(['visual_words/' num2str(word_type) '/' kdesname '_' scene_type '_' num2str(word_type) '.mat']);
  words=rgbdwords;
  K = eval_kernel(words',words',kdes_words.ktype,kdes_words.kparam);
  K = K + 1e-6*eye(size(K));
  G = chol(inv(K));
kdes_words.words=words;
kdes_words.G=G;
