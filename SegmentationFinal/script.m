clc
clear 
close all
%% Definitions
filesdir = '/Users/Shared/Breast/DCE-MRI_mat/';
filesdirOutput = '/Users/Shared/Breast/DCE-MRI_mat-Segmented/';

%% Process all folder
% files = dir(strcat(filesdir,'*.mat'));
% for file = files' 
%     disp('-----------------------------------------------------------------')
%     disp(file.name);
%     fname = strcat(filesdir,file.name);
%     load(fname);
%     SegmentedPatient = zeros(size(stack_all));
%     
%     for k = 1:size(stack_all,1)
%         %disp(k);
%         outputname = strcat(filesdirOutput,'idx_',num2str(k),'_',file.name);
%         img = squeeze(stack_all(k,:,:,:));
%         delete('*.mat')
%         try
%            [mask,PPrimaL, PPrimaR]  = SegmentBreast(img);
%            save(outputname,'mask','PPrimaL', 'PPrimaR');
%         catch
%            disp(strcat('ERROR IN IMAGE: ',file.name,int2str(k)));
%         end
%     end
%     
% end

%% run verification on images folder
filesSegmented = dir(strcat(filesdirOutput,'*.mat'));
for fileSegmented = filesSegmented'
    %% Load the segmented File
    fname=strcat(filesdirOutput,fileSegmented.name);
    OriginalName = fileSegmented.name(7:end);
    index = str2double(fileSegmented.name(5));
    load(fname);  
    %% Load the Original File
    load(strcat(filesdir,OriginalName));
    img = squeeze(stack_all(index,:,:,:));
    % Get the ROI
    imgROI = img(PPrimaL(2):PPrimaR(2),PPrimaR(1):size(img,1),:);
    %% display segmentation
    for x = 1:size(mask,3); 
        subplot(1,2,1),imshow(img(:,:,x),[]) 
        subplot(1,2,2),imshow(imgROI(:,:,x).*mask(:,:,x),[])   
        pause(0.01)
    end
end
