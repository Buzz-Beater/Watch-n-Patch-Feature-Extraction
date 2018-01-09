clear nm;
clear cm;
clear disHyperplane;
clear W L c total accu;

% Calc Normal Margin
if 1
   for i = 1:model.nr_class
       W = norm( model.w( i, : ) );
       nm( i, 1 ) = 1.0 / W;
       %Normal Margin by [Confident Margin‚ð—p‚¢‚½SVM‚Ì‚½‚ß‚Ì“Á’¥—Ê‘I‘ðŽè–@]
   end
   nm = nm';
end

% Calc the distance from hyperplane to test data.
if 1
    for i = 1:length( ttestindex )
        for j = 1:model.nr_class
            W = norm( model.w( j, : ) );
            disHyperplane( i, j ) = decvalues( i, j ) / W;
            %The distance from hyperplane to test data.
        end
    end
end

% Calc Confident Margin
cmlabel = testlabel;
%cmlabel = trainlabel;
if 1
    L = length(cmlabel);
    for i = 1:model.nr_class
        c(1, i) = 0;
    end
    
    for i = 1:L %Per Input Data
        for j = 1:model.nr_class %Per Class Data
            if j == cmlabel(1, i )
                y = 1;
            else
                y = -1;
            end
            %c(1, j) = c(1, j) + cmlabel(1, i)*decvalues(i, j);
            c(1, j) = c(1, j) + y*decvalues(i, j);
        end
    end
    
    for i = 1:model.nr_class
        cm(1, i) = c(1, i) / L * nm(1, i);
    end
            
end

if 1
    for i = 1:model.nr_class
        total(1,i) = 0;
        for j = 1:length(testlabel)
            if testlabel( 1, j ) == i
                total(1,i) = total(1,i) + 1;
            end
        end
        disp(total(1,i));
    end
    
    index = 1;
    for i = 1:model.nr_class
        accu( 1, i ) = 0;
        for j = 1:total(1,i)
            if predictlabel( index, 1 ) == testlabel( 1, index )
                accu(1, i) = accu(1, i) + 1;
            end
            index = index + 1;
        end
        accu( 2, i ) = accu( 1, i ) / total( 1, i ) * 100;
    end
end