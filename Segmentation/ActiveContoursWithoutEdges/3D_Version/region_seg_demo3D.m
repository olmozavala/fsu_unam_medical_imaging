% Coded by: Olmo Zavala (www.olmozavala.com)

close all;
% clear all;
clc;

addpath('../../../ExternalLibs/niftilib');
addpath('../../../ExternalLibs/3drend');
addpath('../../../Paths/'); % Add the paths folder

numberIterations = 100;
displayGraph = true;
alphaVal = .2;

testFolder = true; % Indicates if we are using the test folder or not
dbname = 'DCE-MRI'; % Which DB are we using [DCE-MRI, NME, ...]

folders = setMyPathBreast(testFolder,'DCE-MRI'); % Retrieving folders from production DB

for f = 1:length(folders)
    folder = folders{f};
    addpath(folder);

    display(strcat('Apply algorithm for folder: ',folders{f}));

    %fileName = strcat(folder, '2_enhancedRT_normRed.nii');
    fileName = 'Gradient64.nii';
    I = load_nii(fileName); %-- load the image

    imgData = I.img;
    view_nii(I);

    dims = size(imgData);

    m = zeros(dims(1),dims(2),dims(3)); %-- create initial mask        

    nonzero = (find(imgData > 0)); % Select all the values that were not 0

    % Creating initial mask at the middle of the image
    maxWidth = floor(dims(1)/4);
    maxHeight = floor(dims(2)/4);
    maxDepth= floor(dims(3)/4);

    btmx = floor(dims(1)/2) - maxWidth;
    topx = floor(dims(1)/2) + maxWidth;

    btmy = floor(dims(2)/2) - maxHeight;
    topy = floor(dims(2)/2) + maxHeight;

    btmz = floor(2*dims(3)/3) - maxDepth;
    topz = floor(2*dims(3)/3) + maxDepth;

    m(btmx:topx,btmy:topy,btmz:topz) = 1; % Initial mask        

    [seg timeSDF] = region_seg3D(imgData, m, numberIterations, alphaVal, displayGraph); %-- Run segmentation
end
