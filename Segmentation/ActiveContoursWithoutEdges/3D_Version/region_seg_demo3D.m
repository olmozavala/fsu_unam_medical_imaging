% Coded by: Olmo Zavala (www.olmozavala.com)

close all;
% clear all;
clc;

addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools/');
addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/images/3D/RealExample1/');
addpath('/home/olmozavala/Dropbox/TestImages/nifti/Basics');
addpath('./3drend/');

test = 1;

% matlabpool close force 'local'
% matlabpool 4

resolutions = [32:32:128];
%resolutions = [160];
%fileNamesPrefix = {'Gradient', 'Box'};
fileNamesPrefix = {'Gradient'};
numberIterations = 100;
displayGraph = true;
alphaVal = .2;
numRuns = 10; % How many runs of the same file are we doing (to obtain better times)

AllTimes = zeros(2,length(resolutions), 2); % Last two dims are accumulated time and mean time

for file = 1:2
    time = 0;
    indexRes = 1;
    for res = resolutions
        timeSDFacc = 0;
        for iter = 1:numRuns
            fileName = strcat(fileNamesPrefix{file}, num2str(res), '.nii');
            I = load_nii(fileName); %-- load the image

            imgData = I.img;
            % view_nii(I);

            dims = size(imgData);

            m = zeros(dims(1),dims(2),dims(3)); %-- create initial mask        

            nonzero = (find(imgData > 0)); % Select all the values that were not 0

            % Make those none zero values a little bit visible        

            % Creating initial mask
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

            tic();
            [seg timeSDF] = region_seg3D(imgData, m, numberIterations, alphaVal, displayGraph); %-- Run segmentation
            time = time + toc();
            timeSDFacc = timeSDFacc + timeSDF;
            iter
        end
        display('TimeSDF: ');
        timeSDFacc
        fprintf('File %s Iterations %i accTime: %f \t meanTime %f \r', fileName, numberIterations, time, time/numRuns);
        AllTimes(file,indexRes, :) = [time time/numRuns];        
        indexRes = indexRes+1;
    end
end

save('Times3D','AllTimes')
