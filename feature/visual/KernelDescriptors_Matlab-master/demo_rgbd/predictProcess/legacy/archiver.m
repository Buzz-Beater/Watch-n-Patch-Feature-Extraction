function archiver( savename, kdes_params, model, rgbdwords, maxvalue, minvalue )
%2012/10/09 Written by Hideshi Tsubota @DHRC

archive.kdes_params = kdes_params;
archive.model = model;
archive.rgbdwords = rgbdwords;
archive.maxvalue = maxvalue;
archive.minvalue = minvalue;

save( savename, 'archive' );
%save -v7.3 savename model rgbdwords maxvalue minvalue;
