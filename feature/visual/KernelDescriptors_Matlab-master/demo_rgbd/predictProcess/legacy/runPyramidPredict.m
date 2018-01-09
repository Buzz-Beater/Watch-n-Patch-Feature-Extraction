function [ sum_dec, predictlabels ] = runPyramidPredict( path )

for i = 1:3
    
    switch i
        
        case 1
            [dec_values, predictlabels]=predictkdes_Multi_1x1(path, 'full.mat');
            sum_dec = dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_1x1(path, 'top.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_1x1(path, 'bottom.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_1x1(path, 'left.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_1x1(path, 'right.mat');
            sum_dec = sum_dec + dec_values;
            
            %ŽŸŒ³Šg’£
            for n = 1:5
                for h = 1:2^i
                    for w = 1:2^i
                        layer1( h, w, n ) = sum_dec(1, 1, n);
                    end
                end
            end
            clear sum_dec;
            
        case 2
            [dec_values, predictlabels]=predictkdes_Multi_2x2(path, 'full.mat');
            sum_dec = dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_2x2(path, 'top.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_2x2(path, 'bottom.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_2x2(path, 'left.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_2x2(path, 'right.mat');
            sum_dec = sum_dec + dec_values;
            
            sum_dec = sum_dec + layer1;
            %ŽŸŒ³Šg’£
            for n = 1:5
                for h = 1:2^i
                    for w = 1:2^i
                        x = 0; y = 0;
                        if w < 3
                            x = 1;
                        else
                            x = 2;
                        end
                        
                        if h < 3
                            y = 1;
                        else
                            y = 2;
                        end
                        layer2( h, w, n ) = sum_dec(y, x, n);
                    end
                end
            end
            %clear sum_dec;
            
        case 3
            
            
            
            [dec_values, predictlabels]=predictkdes_Multi_4x4(path, 'full.mat');
            sum_dec = dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_4x4(path, 'top.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_4x4(path, 'bottom.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_4x4(path, 'left.mat');
            sum_dec = sum_dec + dec_values;
            [dec_values, predictlabels]=predictkdes_Multi_4x4(path, 'right.mat');
            sum_dec = sum_dec + dec_values;
            
            %idx = 2^(i-1) * 2^(i-1);
            sum_dec = sum_dec + layer2;
    end
end

predictlabels = combinePredict( sum_dec );
%End

function [predictlabels] = combinePredict( sum_dec )
    
    width = length( sum_dec(1,:,1) );
    height = length( sum_dec(:,1,1) );
    dim = length( sum_dec(1,1,:) );
    
    for h = 1:height
        for w = 1:width
            
            [ value, index ] = max( sum_dec(h, w, : ) );
            predictlabels(h,w) = index;
        end
    end
    