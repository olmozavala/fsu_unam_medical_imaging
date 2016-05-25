close all;
clear all;
clc;

totIterations = 200;

I = imread('brain.jpg');  %-- load the image

m = zeros(size(I,1),size(I,2)); %-- create initial mask matrix

% First two moves over y, last two move over 'x'
m(150:230,200:330) = 1; % Sets the poistion and form of initial mask

originalDim = size(I)        
resize = .2; % Used to resize the image (for speed) 1 -> no resize 

I = imresize(I,resize);  %-- make image smaller 
m = imresize(m,resize);  %     for fast computation

subplot(2,2,1); imshow(I); title('Input Image');
subplot(2,2,2); imshow(m,[0 .1]); title('Initialization');
subplot(2,2,3); title('Segmentation');

display('Performing ACWE');
seg = region_seg(I, m, totIterations,.2,true); %-- Run segmentation
subplot(2,2,4); imshow(seg); title('Global Region-Based Segmentation');

figure
display('Performing ACWE using GPU arrays');
subplot(2,2,1); imshow(I); title('Input Image');
subplot(2,2,2); imshow(m,[0 .1]); title('Initialization');
subplot(2,2,3); title('Segmentation');
seg = region_segGPU(I, m, totIterations,.2,true); %-- Run segmentation

