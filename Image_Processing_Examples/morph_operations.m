function P1_2()
    close all;
    clear all;
    clc;
    img = zeros(10,10);
    img(4:6,4:6) = 1;

    %-- Same example --
    closing = erosion(dilation(img));
    opening = dilation(erosion(img));
    subplot(3,3,1); imshow(img); hold on; title('Example same output');
    subplot(3,3,2); imshow(closing); hold on; title('Closing');
    subplot(3,3,3); imshow(opening); hold on; title('Opening');

    %-- Closing is useful--
    img = zeros(100,100);
    img(40:60,40:60) = 1;
    img(49:50,49:53) = 0;
    closing = dilation(img);
    opening = dilation(erosion(img));
    subplot(3,3,4); imshow(img); hold on; title('Closing useful');
    subplot(3,3,5); imshow(closing); hold on; title('Closing');
    subplot(3,3,6); imshow(opening); hold on; title('Opening');

    %-- Opening is useful--
    img = zeros(20,20);
    img(8:12,4:6) = 1;
    img(8:12,14:16) = 1;
    img(10,4:16) = 1;
    closing = erosion(dilation(img));
    opening = dilation(erosion(img));
    subplot(3,3,7); imshow(img); hold on; title('Opening useful');
    subplot(3,3,8); imshow(closing); hold on; title('Closing');
    subplot(3,3,9); imshow(opening); hold on; title('Opening');


function newImg = dilation(img)
    % - Dilation - 
    mask = [1 1 1; 1 1 1; 1 1 1];
    resConv = conv2(img,mask, 'same');
    newImg = zeros(size(img));
    newImg(resConv >= 1) = 1;

function newImg =  erosion(img)
    % - Erosion - 
    mask = [1 1 1; 1 1 1; 1 1 1];
    resConv = conv2(img,mask, 'same');
    newImg = zeros(size(img));
    newImg(resConv == 9) = 1;
