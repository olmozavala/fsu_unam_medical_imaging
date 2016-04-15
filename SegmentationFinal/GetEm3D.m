function [ EM ] = GetEm3D()
%UNTITLED24 Summary of this function goes here
%   Detailed explanation goes here

%% Load Data
addpath('/Users/macbookpro/PhD/Matlab/niiReader/NIfTI_20140122')
nii=load_nii('/Users/macbookpro/PhD/Data/Testsubject/2.nii');
imgData= nii.img;
DataSize = size (imgData) ;
nImages = DataSize(3);
EM = zeros(DataSize);

waitBar = waitbar(0,'Edge Map calculation...');
steps = nImages;
for x = 1:nImages; 
    img = imgData(:,:,x);
    EM(:,:,x)=EdgeMap(img);
    waitbar(x / steps);
end
close(waitBar)

save('EdgeMap','EM');
end

