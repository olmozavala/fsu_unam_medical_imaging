clc
clear 
close all

% Definitions (it assumes the function setMypath has been executed, and the
% DCE-MRI database is in the path
patientData = '0847664_p6_ok.mat';
load(patientData);

% The DCE-MRI is orientated in a different way that the NME database, so a reorientation is needed first 
stp=flipdim(permute(stack_all,[1 2 4 3]));

%Get the first image of the pateient, and reduce the resolution by interpolation. (It is not necessary but it will be faster) 
stp_reduced=reduce_interp(stp,1.83);
img = squeeze(stp_reduced(1,:,:,:));

%Get a mask that discards the background
[~, mask]=mascara(stp_reduced,0.06);

% Get the Edge Map and plot it
[EM]=EdgeMap3D(img,~mask);
bmp_stack(EM,10,3);
