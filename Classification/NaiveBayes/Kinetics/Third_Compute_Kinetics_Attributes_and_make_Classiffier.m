% This function reads the curves for each class, obtain a list of features from them, creates a classifier 
function makeClassifier()
close all;
clear all;
clc;

addpath('../../../ExternalLibs/niftilib');
addpath('./Kinetic_Curves_by_classes/');
addpath('../../../Paths/'); % Add the paths folder


testFolder = false;
filesFolder = './Data_Positions/';
saveFolder = './Kinetic_Curves_by_classes/';
imagesPath = getMyPath(testFolder,'DCE-MRI');
folders = setMyPathBreast(testFolder,'DCE-MRI'); % Retrieving folders from production DB

addpath(imagesPath);

% ----------- Reads the curves for each class ----------
fprintf('Reading the curves...\n'); 
load('lesions.mat')
load('nolesions.mat')

fprintf('Plotting the mean curves...\n'); 
hold on
plot(mean(lesion),'r','LineWidth',3);
plot(mean(nolesion),'k','LineWidth',3);
legend( 'Lesion','No Lessoin') ;
pause(.2);
figure
hold on
plot(lesion','--r','LineWidth',1);
plot(nolesion','--k','LineWidth',1);

% ========= Put everything in a big matrix =======
% The attributes are:
% intensities  [1:5] 
% slopes       [6:9]
% mean value   [10] 
% time to peak [11]
% time of max slope [12]
% non-decreasing function [13]

% 5 files x 25 lesions x 25 no lesions
fprintf('Putting everything ina big matrix...');
totFiles = 5;
totExamplesL = 25;
totExamplesNL = 95;
totSize = totFiles*(totExamplesL+totExamplesNL);
attributes = 13;
curveMatrix = zeros(totSize,attributes);
outputVector = zeros(totSize,1);
classes = {'No lession 0','Lesion 1'};
currIdx = 1;

% ------ Fill lesions ------
currSize = totExamplesL*totFiles;
curveMatrix(1:currIdx+currSize-1,1:5) = lesion;
outputVector(1:currIdx+currSize-1) = 1;

% ------ Fill no lesions ------
currIdx = currIdx+currSize;
currSize = totExamplesNL*totFiles;
curveMatrix(currIdx:currIdx+currSize-1,1:5) = nolesion;
outputVector(currIdx:currIdx+currSize-1) = 0;

%------------------ Compute slopes -------------
curveMatrix(:,6) = curveMatrix(:,2) - curveMatrix(:,1);
curveMatrix(:,7) = curveMatrix(:,3) - curveMatrix(:,2);
curveMatrix(:,8) = curveMatrix(:,4) - curveMatrix(:,3);
curveMatrix(:,9) = curveMatrix(:,5) - curveMatrix(:,4);

%------------------ Compute mean -------------
curveMatrix(:,10) = mean( curveMatrix(:,1:5),2 );

%------------------ Compute time to peak -------------
[del curveMatrix(:,11)] = max( curveMatrix(:,1:5)');

%------------------ Compute time of max slope -------------
[del curveMatrix(:,12)] = max( curveMatrix(:,6:9)');

%------------------ No 'sharp' decrease -------------
curveMatrix(:,13) = min( (curveMatrix(:,6:9) > -5)')';

% ======================== Construct NB classifier ==========================================
%fprintf('Making the classifiers...\n');
%NBClassifier = fitcnb(curveMatrix, outputVector)
%isGenRate = resubLoss(NBClassifier);
%fprintf('Naive Bayes classification error of %4.2f % \n',isGenRate*100);

TreesClassifier = fitctree(curveMatrix, outputVector)
isGenRate = resubLoss(TreesClassifier);
fprintf('Regression Trees classification error of %4.2f % \n',isGenRate*100);

% ======================== Classify images ==========================================
fprintf('Classifiying the images...\n');

% Iterate over foldersg
for i = 1:length(folders)
    folder = folders{i};
    % Read all 5 niftis
    fprintf('\nReading nifti files for: %s ... \n',folders{i});
    niftis = readNifti(folder);

    % -------------- Apply the Regression tree classifier into the image ------------- 
    classified = makeMagic(niftis, TreesClassifier);
    % --------------- Saving classification of the matrix features ------------
    save(strcat(folder,'/ClassifiedPixels.mat'),'classified')
    
%
%    % -------------- Apply the NB classifier into the image ------------- 
%    classified = makeMagic(niftis, NBClassifier);
%    % --------------- Saving classification of the matrix features ------------
%    save(strcat(imagesPath,folder,'/ClassifiedPixelsNB.mat'),'classified')
end

% This function is used to read 5 nifti files for each folder
function niftis = readNifti(folder)
    for i=1:5
        fileName = strcat(folder,'/',num2str(i),'.nii');
        nii = load_nii(fileName);
        % We smooth the image with gaussian blur
        niftis(i,:,:,:) = smooth3(nii.img);
    end

% This function classifies a DCE-MRI image using one classifier
function result = makeMagic(niftis, nb)
    % Iterate over the images
    dims = size(niftis);
    totPixelsPerVolume = dims(2)*dims(3)*dims(4);
    totNumberOfFiles = dims(1);
    numAttribs = 13;
    curveMatrix = zeros(totPixelsPerVolume,numAttribs);

    % Fill the curves with the intensity values
    display('Filling matrix with kinetic values....')
    for i=1:totNumberOfFiles
        curveMatrix(:,i) = squeeze(niftis(i,:));
    end

    display('Computing slopes of kinetic info....')
    %------------------ Compute slopes -------------
    curveMatrix(:,6) = curveMatrix(:,2) - curveMatrix(:,1);
    curveMatrix(:,7) = curveMatrix(:,3) - curveMatrix(:,2);
    curveMatrix(:,8) = curveMatrix(:,4) - curveMatrix(:,3);
    curveMatrix(:,9) = curveMatrix(:,5) - curveMatrix(:,4);

    %------------------ Compute mean -------------
    display('Computing mean of kinetic info....')
    curveMatrix(:,10) = mean( curveMatrix(:,1:5),2 );

    %------------------ Compute time to peak -------------
    display('Computing time to peak....')
    [del curveMatrix(:,11)] = max( curveMatrix(:,1:5)');

    %------------------ Compute time of max slope -------------
    [del curveMatrix(:,12)] = max( curveMatrix(:,6:9)');

    %------------------ No 'sharp' decrease -------------
    curveMatrix(:,13) = min( (curveMatrix(:,6:9) > -5)')';

    % --------- Evaluate the classifier ---------
    display('Classifying the features matrix....')
    result = predict(nb,curveMatrix);
    result = reshape(result,[dims(2),dims(3),dims(4)]);
