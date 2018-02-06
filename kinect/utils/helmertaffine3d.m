function [tp,ac,tr]=helmertaffine3d(datum1,datum2,NameToSave)

% HERLMERTAFFINE3D    overdetermined cartesian 3D affine transformation ("Helmert-Transformation")
%
% [param, accur, resid] = helmertaffine3D(datum1,datum2,SaveIt)
%
% Inputs:  datum1  n x 3 - matrix with coordinates in the origin datum (x y z)
%                  datum1 may also be a file name with ASCII data to be processed. No point IDs, only
%                  coordinates as if it was a matrix.
%
%          datum2  n x 3 - matrix with coordinates in the destination datum (x y z)
%                  datum2 may also be a file name with ASCII data to be processed. No point IDs, only
%                  coordinates as if it was a matrix.
%                  If some coordinates of datum2 are missing (e.g. a 2D point is used together with 
%                  3D points), NaN has to be used at the gap.
%                  If either datum1 and/or datum2 are ASCII files, make sure that they are of same
%                  length and contain corresponding points. there is no auto-assignment of points!
%
%          SaveIt  string with the name to save the resulting parameters in Transformations.mat.
%                  Make sure only to use characters which are allowed in Matlab variable names
%                  (e.g. no spaces, umlaute, leading numbers etc.)
%                  If left out or empty, no storage is done.
%                  If the iteration is not converging, no storage is done and a warning is thrown.
%                  If the name to store already is existing, it is not overwritten automatically.
%                  To overwrite an existing name, add '#o' to the name, e.g. 'wgs84_to_local#o'.
%
% Outputs:  param  12 x 1 Parameter set of the 3D affine transformation
%                      3 translations (x y z) in [Unit of datums]
%                      9 affine parameters 
%
%           accur  12 x 1 accuracy of the parameters
%
%           resid  n x 3 - matrix with the residuals datum2 - f(datum1,param)
%
% Used to calculate affine transformation parameters when at least 4 identical points in both systems
% are known. An affine transformation is a linear transformation using 12 parameters.
% Parameters can be used with d3affinetrafo.m

% 11/12/19 Peter Wasmeier - Technische Universitt Mnchen
% p.wasmeier@bv.tum.de
% 04/17/15 Andrea Pinna - University degli Studi di Cagliari
% andrea.pinna@unica.it
 
%% Argument checking and defaults

if nargin<3
    NameToSave=[];
else
    NameToSave=strtrim(NameToSave);
    if strcmp(NameToSave,'#o')
        NameToSave=[];
    end
end

% Load input file if specified
if ischar(datum1)
    datum1=load(datum1);
end
if ischar(datum2)
    datum2=load(datum2);
end

if (size(datum1,1)==3)&&(size(datum1,2)~=3)
    datum1=datum1'; 
end
if (size(datum2,1)==3)&&(size(datum2,2)~=3)
    datum2=datum2'; 
end

s1=size(datum1);
s2=size(datum2);
if any(s1~=s2)
    error('The datum sets are not of equal size')
elseif any([s1(2) s2(2)]~=[3 3])
    error('At least one of the datum sets is not 3D')
elseif any([s1(1) s2(1)]<4)
    error('At least 4 points in each datum are necessary for calculating')
elseif any(isnan(datum1))
    error('NaN are not allowed in the origin datum; complete 3D coordinates are necessary there.')
elseif prod(s2)-sum(sum(isnan(datum2))) < 12
    error('At least 12 coordinates in the destination datum are necessary')
end

%% Linear affine transformation:

% Make nearly singular matrix warning an error
s = warning('error','MATLAB:nearlySingularMatrix');

G=zeros(3*s1(1),12);
E1 = ones(s1(1),1);
Z1 = zeros(s1(1),1);
Z3 = zeros(s1);
G(1:3:end,:) = [E1, Z1, Z1, datum1, Z3, Z3];
G(2:3:end,:) = [Z1, E1, Z1, Z3, datum1, Z3];
G(3:3:end,:) = [Z1, Z1, E1, Z3, Z3, datum1];
t = reshape(datum2.',3*s2(1),1);
nans=find(isnan(datum2'));
G(nans,:)=[];
t(nans)=[];

GpG = G' * G;
tp = GpG \ (G'*t);
if (size(G,1)>12)
    v=G*tp-t;
    sig0p=sqrt((v'*v)/(size(G,1)-12));
    try
        ac=sqrt(diag(sig0p^2*inv(GpG)));
    catch
        ac=sqrt(diag(sig0p^2*pinv(GpG)));
    end
else
    ac=zeros(12,1);
end

% Restore warning
warning(s);

%% Transformation residuals
rot_datum1 = ([tp(4:6)';tp(7:9)';tp(10:12)'] * datum1')';
idz = bsxfun(@plus,tp(1:3),rot_datum1')';

tr = datum2 - idz;

%% Store data

if ~isempty(NameToSave)
    load Transformations;
    if exist(NameToSave,'var') && length(NameToSave)>=2 && ~strcmp(NameToSave(end-1:end),'#o')
        warning('Helmert3D:Parameter_already_exists',['Parameter set ',NameToSave,' already exists and therefore is not stored.'])
    else
        if strcmp(NameToSave(end-1:end),'#o')
            NameToSave=NameToSave(1:end-2);
        end
        if any(regexp(NameToSave,'\W')) || any(regexp(NameToSave(1),'\d'))
            warning('Helmert3D:Parameter_name_invalid',['Name ',NameToSave,' contains invalid characters and therefore is not stored.'])
        else
            eval([NameToSave,'=[',num2str(tp'),'];']);
            save('Transformations.mat',NameToSave,'-append');
        end
    end
end
