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
    % Max intensity value [14]

    % 5 files x 25 lesions x 25 no lesions
    fprintf('Putting everything ina big matrix...');
    totFiles = 5;
    totExamplesL = 25;
    totExamplesNL = 95;
    totSize = totFiles*(totExamplesL+totExamplesNL);
    attributes = 14;
    curveMatrix = zeros(totSize,attributes);
    outputVector = zeros(totSize,1);
    classes = {'No lession 0','Lesion 1'};
    currIdx = 1;

    % ------ Fill lesions ------
    currSize = totExamplesL*totFiles;
    curveMatrix(1:currIdx+currSize-1,:) = ComputeAttributes(lesion);
    outputVector(1:currIdx+currSize-1) = 1;

    % ------ Fill no lesions ------
    currIdx = currIdx+currSize;
    currSize = totExamplesNL*totFiles;
    curveMatrix(currIdx:currIdx+currSize-1,:) = ComputeAttributes(nolesion);
    outputVector(currIdx:currIdx+currSize-1) = 0;

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

    % Folders with chest segmentation
    filesdirOutput = strcat(imagesPath,'DCE-MRI-Segmented-from-Mat/DCE-MRI_mat-Segmented/');

    % Iterate over foldersg
    for i = 1:length(folders)
        folder = folders{i};

        % Read all 5 niftis
        fprintf('\nReading nifti files for: %s ... \n',folders{i});
        normalized = true;
        smoothed = true;
        niftis = readNifti(folder,normalized,smoothed);

        % -------------- Apply the Regression tree classifier into the image ------------- 
        temp = makeMagic(niftis, TreesClassifier);

        % ----------- Removing chest segmentation -------
        fname = strcat(filesdirOutput, 'idx_2_',getLastFolder(folders{i}),'.mat');
        load(fname);  
        classified = zeros(size(temp));
        classified(PPrimaL(2):PPrimaR(2),PPrimaR(1):size(niftis,2),:) = ...
                    temp(PPrimaL(2):PPrimaR(2),PPrimaR(1):size(niftis,2),:).*mask;

        % --------------- Saving classification of the matrix features ------------
        save(strcat(folder,'/ClassifiedPixels.mat'),'classified')
        %
        %    % -------------- Apply the NB classifier into the image ------------- 
        %    classified = makeMagic(niftis, NBClassifier);
        %    % --------------- Saving classification of the matrix features ------------
        %    save(strcat(imagesPath,folder,'/ClassifiedPixelsNB.mat'),'classified')
    end
end


    % This function classifies a DCE-MRI image using one classifier
function result = makeMagic(niftis, nb)
    % Iterate over the images
    dims = size(niftis);
    totCurves = dims(2)*dims(3)*dims(4);
    curves = zeros(totCurves, dims(1));

    for i = 1:dims(1);
        curves(:,i) = squeeze(niftis(i,:));
    end

    % Fill the curves with the intensity values
    display('Filling matrix with kinetic values....')
    curveMatrix = ComputeAttributes(curves);

    % --------- Evaluate the classifier ---------
    display('Classifying the features matrix....')
    result = predict(nb,curveMatrix);
    result = reshape(result,[dims(2),dims(3),dims(4)]);
end
