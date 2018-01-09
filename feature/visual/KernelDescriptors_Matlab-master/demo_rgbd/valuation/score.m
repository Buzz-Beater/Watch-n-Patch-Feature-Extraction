function [ score, accuracy ] = score(distance, predictlabel, testlabel)
% 2012/09/26 Written by Hideshi Tsubota @DHRC
% Scoring Function

pl = predictlabel;
tl = testlabel';

nr_class = length(unique(tl));
nr_test = length(distance);

%score = zero( nr_class, 1 );
for i = 1:nr_class
    sum_targetclass = 0;
    sum_restclass = 0;
    targetcount = 0;
    restcount = 0;
    
    correct = 0;
    
    for j = 1:nr_test
        if i == tl(j)
            sum_targetclass = sum_targetclass + distance(j,i);
            targetcount = targetcount + 1;
            
            if pl(j) == tl(j)
                correct = correct + 1;
            end
        else
            sum_restclass = sum_restclass + distance(j,i);
            restcount = restcount + 1;
        end
                
    end
    
    %disp( targetcount );
    %disp( sum_targetclass/targetcount );
    %disp( sum_restclass/restcount );
    score(i,1) = sum_targetclass / targetcount + -1 * sum_restclass / restcount;
    
    accuracy(i,1) = targetcount;%クラス毎のテストデータ数
    accuracy(i,2) = correct;%クラス毎の正解数
    accuracy(i,3) = accuracy(i,2)/accuracy(i,1);%認識率
end
