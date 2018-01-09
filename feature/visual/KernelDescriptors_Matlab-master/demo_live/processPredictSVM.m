%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ decvalues, predictlabel ] = processPredictSVM( fea, model, SVM_TYPE )
%
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testhmp = fea; 
if SVM_TYPE ~= 0
     testhmp = double( testhmp );
     testhmp = sparse( testhmp );
end

testhmp = scaletest( testhmp, 'linear', model.svm.minvalue, model.svm.maxvalue );
testlabel = 1;%this is no meaning

if SVM_TYPE == 2
    [ predictlabel, accuracy, decvalues ] = svmpredict( testlabel', testhmp', model.matlab.model );
else
    [ predictlabel, accuracy, decvalues ] = predict( testlabel', testhmp', model.matlab.model );
end 