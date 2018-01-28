function [feaSet] = gen_fea(I, kdes_params, kdes_type)
    switch kdes_type
        case {'gradkdes', 'gradkdes_dep'}
            feaSet = gradkdes_dense(I, kdes_params);
        case {'lbpkdes', 'lbpkdes_dep'}
            feaSet = lbpkdes_dense(I, kdes_params);
        case 'normalkdes'
            feaSet = normalkdes_dense(I, kdes_params);
        case 'rgbkdes'
            feaSet = rgbkdes_dense(I, kdes_params);
        case 'nrgbkdes'
            feaSet = nrgbkdes_dense(I, kdes_params);
        case 'spinkdes'
            feaSet = spinkdes_dense(I, kdes_params);
        otherwise
            fprintf('No kernel available');
    end
end