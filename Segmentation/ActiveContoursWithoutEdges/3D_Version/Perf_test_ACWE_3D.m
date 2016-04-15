function perfTestSDF3D()
    close all;
    clear all;
    clc;

    addpath('/home/olmozavala/Dropbox/OzOpenCL/Matlab_CreateNifti/External_Tools');
    addpath('./3drend/');

    % matlabpool close force 'local'
    % matlabpool 4

    sizes = [32:32:352];
    totIter = 100;
    runs  = 5; % Number of runs to average
    alphaVal = .2;
    displaySeg = false;
    folderFiles = '/home/olmozavala/Dropbox/TestImages/nifti/Basics/Gradient';

    allMeanTimes = zeros(length(sizes),2);

    for imgsize=1:length(sizes)
        fileName = strcat(folderFiles,num2str(sizes(imgsize)),'.nii');
        fprintf('Image: %s ...\n',fileName);
        accTime = 0;
        for i=1:runs
            fprintf('Run %d ...\n',i);
            imgData = load_nii(fileName); %-- load the image

            I = imgData.img;
            % view_nii(I);

            [w h d] = size(I);
            m = zeros(w,h,d);          %-- create initial mask        

            maskWidthSize= floor(w/4);
            maskHeightSize= floor(h/4);
            maskDepthSize= floor(d/4);

            % First two moves over y last two move over 'x'
            m( (w/2-maskWidthSize):(w/2+maskWidthSize),  ...
               (h/2-maskHeightSize):(h/2+maskHeightSize), ...
               (d/2-maskDepthSize):(d/2+maskDepthSize)) = 1;

            % Start SDF
            tic();
            [seg temp]= region_seg3D(I, m, totIter, alphaVal, displaySeg); %-- Run segmentation
            accTime = accTime + toc();

        end

        % Display mask and SDF
        if(displaySeg)
            figure('Position',[100*imgsize,100,1000,600]); hold on;
            subplot(1,3,1); 
            view3DOZ(double(I),-1,1);    
            subplot(1,3,2); 
            view3DOZ(double(m),-1,1);    
            subplot(1,3,3); 
            view3DOZ(double(seg),-1,1);    
            pause(1);
        end
        meanTime = accTime/runs;
        allMeanTimes(imgsize,:) = [sizes(imgsize), meanTime]; 
        fprintf('Mean time: %4.2f \n',meanTime);
        
        save('Times3DACWE','allMeanTimes');
    end


    function phi = mask2phi(init_a)
        phi=bwdist(init_a)-bwdist(1-init_a)+im2double(init_a)-.5;

