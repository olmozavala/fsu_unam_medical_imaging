clear
close all
clc
%% Load Data
addpath('/Users/macbookpro/PhD/Matlab/niiReader/NIfTI_20140122')
nii=load_nii('/Users/macbookpro/PhD/Data/Testsubject/1.nii');
imgData= nii.img;

%% Get the Roi From Middle Slice
[roiymin, roiymax, roixmin,roixmax]=getRoiFromNii(imgData) ;


%% Get Image
DataSize = size (imgData) ;
nimages= DataSize(3);
img = imgData(:,:,floor(nimages/2));
%img = img./max(img(:));
imageSize = size(img);
numRows = imageSize(1);
numCols = imageSize(2);


%% Call the enhancement algorithm
testfin(img);