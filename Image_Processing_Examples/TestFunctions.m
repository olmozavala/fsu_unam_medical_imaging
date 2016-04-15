%% Olmo Zavala
function TestFunctions();
    close all;
    clear all;
    clc;

    % Read image
    img = imread('../../Test_Data/Sample_images/1.jpg');
    imgSmall = imread('../../Test_Data/Sample_images/lena_256.pgm');

    %histogram(img);% Histogram
    %CD(img); % Cummulative Distribution
    %convolution(imgSmall);
    %sobel(imgSmall);
    geom_trans();
    %morph();
    %lapPyr(imgSmall);

    % =================== Histogram ================== 
function histogram(img)
    [hr hg hb] = oz_allhist(img);
    hrmat = imhist(img(:,:,1)); %Same function but by matlab

    figure('Position', [2000, 100, 1400, 500]);
    subplot(1,3,1); imshow(img);
    subplot(1,3,2); plot(hr,'r'); hold on; plot(hg,'g');plot(hb,'b'); xlim([0 255]); grid;

    % ================== Cummulative distribution ================== 
function CD(img)
    [hr hg hb] = oz_allhist(img);

    cdr = oz_cumdist(hr);
    cdg = oz_cumdist(hg);
    cdb = oz_cumdist(hb);
    subplot(1,3,3); plot(cdr,'r'); hold on; plot(cdg,'g');plot(cdb,'b'); xlim([0 255]); grid;

    %===================== Convolution transformations ===================
function convolution(img)
    n = 10;
    sigma = .5;
    mask = oz_gaussMask(n,sigma);
    figure 
    subplot(1,2,1), imshow(img);
    convImgR = oz_conv(img,mask);
    subplot(1,2,2), imshow(convImgR);

    %===================== Edge detection (sobel) ===================
function sobel(img)
    mask = [-1 0 1; -2 0 2; -1 0 1]; 

    imgx = conv2(img,mask, 'same');
    figure('Position', [2000, 100, 1400, 500]);
    subplot(1,3,1), imshow(uint8(img));
    subplot(1,3,2), imshow(uint8(imgx));
    mask = mask';
    imgy = conv2(img,mask, 'same');
    subplot(1,3,3), imshow(uint8(imgy));

    %===================== Geometric transformations ===================
function geom_trans()
    % Initializes the grid
    x = [-1:.1:1];
    y = [-1:.1:1];
    fontsize = 20;

    figure('Position', [1000, 100, 1400, 800]);
    [X Y] = meshgrid(x,y);
    subplot(2,3,1); plot(X,Y, '*b')
    title('Original','FontSize', fontsize); xlim([-1 1]); ylim([-1 1]);

    % Grid rotated -30 Degrees
    angle = -30;
    rotmat = [ cosd(angle) -sind(angle) 0;
               sind(angle) cosd(angle) 0];

    [Xnew Ynew] = apply_trans(X,Y,rotmat);
    subplot(2,3,2); hold on; plot(Xnew, Ynew, '*b')
    title('Rotated','FontSize', fontsize);

    % Scaled grid
    scale = [.75 0 0
            0 .60 0];

    [Xnew Ynew] = apply_trans(X,Y,scale);
    subplot(2,3,3); hold on; plot(Xnew,Ynew, '*b')
    title('Scaled','FontSize', fontsize); xlim([-1 1]); ylim([-1 1])

    % Affine transformation
    affMat = [1.25 -.25 .15;
            .25 .8 -.25];

    [Xnew Ynew] = apply_trans(X,Y,affMat);
    subplot(2,3,4); hold on; plot(Xnew,Ynew, '*b')
    title('Affine','FontSize', fontsize);

    % Perspective
    Xpers = X; Ypers = X;
    for i=1:length(x)
        for j=1:length(x)
            Xpers(i,j) = X(i,j)/(2*Y(i,j)/3 + 4/3)';
            Ypers(i,j) = 1.5*Y(i,j)/(2*Y(i,j)/3 + 4/3);
        end
    end
    subplot(2,3,5); hold on; plot(Xpers,Ypers, '*b')
    title('Perspective','FontSize', fontsize);

% ------------ Apply a normal geometric transformation (not perspective)
    function [newX, newY] = apply_trans(X,Y,matrix)
        newX = zeros(size(X));
        newY = zeros(size(Y));
        for i=1:length(X)
            for j=1:length(X)
                newVect = matrix*[X(i,j) Y(i,j) 1]';
                newX(i,j) = newVect(1);
                newY(i,j) = newVect(2);
            end
        end


    %===================== Morphology operations ===================
function morph()
    img = zeros(10,10);
    img(4:6,4:6) = 1;
    img(5,5) = 0;

    subplot(1,4,1); imshow(img);
    % - Dilation - 
    dilation = [1 1 1; 1 1 1; 1 1 1];
    newImg = conv2(img,dilation, 'same');
    newImg(newImg >= 1) = 1;
    subplot(1,4,2); imshow(newImg);

    % - Erosion - 
    erosion = [1/9 1/9 1/9; 1/9 1/9 1/9; 1/9 1/9 1/9];
    newImg = conv2(img,erosion, 'same');
    newImg(newImg < 1) = 0;
    subplot(1,4,3); imshow(newImg);

    %===================== Laplacian pyrmid for 2n^n image size ===================
function lapPyr(img)
    oz_laplacianPyramid(img);
