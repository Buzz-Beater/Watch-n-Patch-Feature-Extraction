function [feaSet] = gen_fea(I, kdes_params, kdes_type)
    switch kdes_type
        case {'gradkdes', 'gradkdes_dep'}
            if strcmp(kdes_type, 'gradkdes_dep')
                I = double(I) / 1000;
            end
            feaSet = gradkdes_dense(I, kdes_params);
        case {'lbpkdes', 'lbpkdes_dep'}
            feaSet = lbpkdes_dense(I, kdes_params);
        case 'normalkdes'
            pcloud = depthtocloud(I);
            pcloud = pcloud ./ 1000;
            feaSet = normalkdes_dense(pcloud, kdes_params);
        case 'rgbkdes'
            feaSet = rgbkdes_dense(I, kdes_params);
        case 'nrgbkdes'
            feaSet = nrgbkdes_dense(I, kdes_params);
        case 'spinkdes'
            pcloud = depthtocloud(I);
            pcloud = pcloud ./ 1000;
            normal = fix_noraml_orientation(pcloud);
            feaSet = spinkdes_dense(pcloud, normal, kdes_params);
        otherwise
            fprintf('No kernel available');
    end
end