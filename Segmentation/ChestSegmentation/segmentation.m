clear
close all
%% Load nii Data
addpath('../../ExternalLibs/niftilib')
nii=load_nii('../../../Test_Data/DCE-MRI/Simple/1.nii');
imgData= nii.img;
%view_nii(nii);

%% Get Image
DataSize = size (imgData) ;
nimages= DataSize(3);
img = imgData(:,:,floor(nimages/2));
img = img./max(img(:));
imageSize = size(img);
numRows = imageSize(1);
numCols = imageSize(2);
tic
% Save a Copy of the Original Image
imgOriginal = img;
imshow(img);
title('Original Image');
display('Original image, click to continue...');
waitforbuttonpress
%% Remove noise from image with gaussian
%img = imgaussfilt(img,1);
img = medfilt2(img, [3 3]);
imshow(img);
title('Median Filtered Image');
display('Median filtered image, click to continue...');
waitforbuttonpress

%% Get the body Fat Mask
display('Performing segmentation (it may take some time)...');
bodyfatmask = getBodyFatMask(img);
imshow(bodyfatmask,[]); 
title('Body Fat Mask Cluster')
display('Done! ');
waitforbuttonpress

SE = strel('disk',1,0);
bodyfatmask = imopen(bodyfatmask, SE);
imshow(bodyfatmask,[]); 
title('Body Fat Mask - Open')
waitforbuttonpress

bodyfatmask = imfill(bodyfatmask, 'holes');
imshow(bodyfatmask,[]); 
title('Body Fat Mask - Fill')
waitforbuttonpress

bodyfatmask = bwareaopen(bodyfatmask,4000);
imshow(bodyfatmask,[]); 
title('Body Fat Mask - Area Opening')
waitforbuttonpress

%% The detected area
img = img.*bodyfatmask;
imshow(img,[]); 
title('Body Fat')
waitforbuttonpress

