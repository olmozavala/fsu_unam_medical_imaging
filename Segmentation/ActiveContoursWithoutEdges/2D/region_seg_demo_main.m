close all;
clear all;
clc;

test = 5;
totIterations = 200;

addpath('../../../../Test_Data/Sample_images');
switch(test)
    case 1
        I = imread('airplane.jpg');  %-- load the image
        
        m = zeros(size(I,1),size(I,2));          %-- create initial mask        
        % First two moves over y last two move over 'x'
        m(100:130,200:230) = 1; % Good for the airlplane        
        
        originalDim = size(I)        
        resize = 1; % Resize both images, the orginal and the mask             
    case 2
        I = imread('test1.jpg');  %-- load the image       
        
        m = zeros(size(I,1),size(I,2));          %-- create initial mask        
        % First two moves over y last two move over 'x'
        m(700:900,1000:1200) = 1; % Change with respect to original image
        
        originalDim = size(I)        
        resize = .1; % Resize both images, the orginal and the mask                             
    case 3
        I = imread('test2.jpg');  %-- load the image
        m = zeros(size(I,1),size(I,2));          %-- create initial mask        
        % First two moves over y last two move over 'x'
        m(800:900,1000:1200) = 1; % Change with respect to original image
        
        originalDim = size(I)        
        resize = .1; % Resize both images, the orginal and the mask     
    case 4
        I = imread('RectangularIn.png');  %-- load the image
        m = zeros(size(I,1),size(I,2));          %-- create initial mask        
        % First two moves over rows last two move over columns
        m(150:250,350:450) = .1; % Change with respect to original image
        
        originalDim = size(I)        
        resize = 1; % Resize both images, the orginal and the mask 
    case 5
        I = imread('RectTest1.png');  %-- load the image
        m = zeros(size(I,1),size(I,2));          %-- create initial mask        
        % First two moves over rows last two move over columns
%         m(150:250,350:450) = .1; % Change with respect to original image
        m(100:200,350:450) = .1; % Change with respect to original image
        
        originalDim = size(I)        
        resize = 1; % Resize both images, the orginal and the mask
  case 6
        I = imread('RealTest1.jpg');  %-- load the image
        m = zeros(size(I,1),size(I,2));          %-- create initial mask        
        % First two moves over rows last two move over columns
        m(1500:1800,2900:3000) = .1; % Change with respect to original image
        
        originalDim = size(I)        
        resize = .1; % Resize both images, the orginal and the mask
case 7
        I = imread('SmallRealTest.png');  %-- load the image
        m = zeros(size(I,1),size(I,2));          %-- create initial mask        
        % First two moves over rows last two move over columns
        m(500:600,800:900) = 1; % Change with respect to original image
        
        originalDim = size(I)        
        resize = 1; % Resize bot        
end

I = imresize(I,resize);  %-- make image smaller 
m = imresize(m,resize);  %     for fast computation

subplot(2,2,1); imshow(I); title('Input Image');
subplot(2,2,2); imshow(m,[0 .1]); title('Initialization');
subplot(2,2,3); title('Segmentation');

display('Normal segmentation');
seg = region_seg(I, m, totIterations,.2,true); %-- Run segmentation

%display('GPU segmentation');
%seg = region_segGPU(I, m, 120); %-- Run segmentation

subplot(2,2,4); imshow(seg); title('Global Region-Based Segmentation');
