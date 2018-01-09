[decvalue, predictlabel] = predictkdes_Multi( './deptest/env_dep.png', model, rgbdwords, maxvalue, minvalue);
bar3(decvalue(:,:,1))
xlabel('X');
