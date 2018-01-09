function [out,data] = reshape( XYZ )

dim = 3;
data = length(XYZ(1,:));

for i = 1:data
    out(1,i,1) = XYZ(1,i) * 1000.0;
    out(1,i,2) = XYZ(2,i) * 1000.0;
    out(1,i,3) = XYZ(3,i) * 1000.0;
end