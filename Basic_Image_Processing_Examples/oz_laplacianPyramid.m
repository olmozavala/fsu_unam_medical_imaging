%% Problem 1. Write a program to generate a Laplacian pyramid of an image. 
function oz_laplacianPyramid(img)

img = double(img);%Make it double
figure('Position',[200 200 1200 400])
hold on

kernelSize = 5;% Size of Gaussian kernel (5x5)
sigma = 1.0;% Sigma used for Gaussian
gaussMask = oz_gaussMask(kernelSize, sigma);

imgDims = size(img);

% This variable is used to store the gaussian versions at lower resolutions (discarded at the end)
gaussPyr =zeros(imgDims(1), imgDims(2)*(3/2)+1);

currDimRows = imgDims(1);
currDimCols = imgDims(2);

currIter = 1;
rowsStart = 1;%Indicates where to store the image
allRowStarts(1) = 1;% Saves all the positions where the images are located

% We first do the Gaussians and create the pyramid
while currDimRows > 8 
    % Step 1 apply gauss
    if(currIter == 1)
        % Step 2 save on temporal variable
        gaussPyr(1:currDimRows,1:currDimCols) = conv2(img,gaussMask,'same' );
        % Step 3 do pyramid
        %tempGauss = oz_pyramid(gaussPyr(1:currDimRows,1:currDimCols));
        tempGauss = impyramid(gaussPyr(1:currDimRows,1:currDimCols),'reduce');
    else
        currDimRows = currDimRows/2;
        currDimCols = currDimCols/2;
        % Step 2 save on temporal variable
        gaussPyr(rowsStart:rowsStart+currDimCols-1,imgDims(2)+1:imgDims(2)+currDimCols) = ...
            conv2(tempGauss,gaussMask,'same');
        % Step 3 do pyramid
        %tempGauss = oz_pyramid(gaussPyr(rowsStart:rowsStart+currDimCols-1,imgDims(2)+1:imgDims(2)+currDimCols));
        tempGauss = impyramid(gaussPyr(rowsStart:rowsStart+currDimCols-1,imgDims(2)+1:imgDims(2)+currDimCols),'reduce');
        rowsStart = rowsStart + currDimRows;
        allRowStarts(currIter) = rowsStart;
    end
    currIter = currIter + 1;
end
subplot(1,2,1),imshow(uint8(gaussPyr));
title('Gaussian pyramid');

% The first image we analize is 8x8
currDimRows = currDimRows*2;
currDimCols = currDimCols*2;

% Initialize the Laplace pyramid with the values of the the Gauss pyramid
lapPyr = gaussPyr;
currIter = currIter - 1;
minRow = 0;
maxRow = 0;
minCol = 0;
maxCol = 0;
minRowPrev = 0;
maxRowPrev = 0;
minColPrev = 0;
maxColPrev = 0;

% We then, do the upsampling and obtain the 'laplacian' for each level
while currIter >  1
    % Define the indexes that will be used to put the image in the right spot
    if(currIter == 2)
        minRow = 1;
        maxRow = currDimRows;
        minCol = 1;
        maxCol = currDimCols;
    else
        minRow = allRowStarts(currIter-2);
        maxRow = allRowStarts(currIter-2)+currDimRows -1;
        minCol = imgDims(2)+1;
        maxCol = imgDims(2)+currDimCols;
    end

    minRowPrev = allRowStarts(currIter-1);
    maxRowPrev = allRowStarts(currIter-1)+currDimCols/2-1;
    minColPrev = imgDims(2)+1;
    maxColPrev = imgDims(2)+currDimCols/2;

    % Step 1 Do upsampling
    lapPyr(minRow:maxRow, minCol:maxCol) = ...
        oz_upsample(gaussPyr(minRowPrev:maxRowPrev,minColPrev:maxColPrev) , 'simplest');

    % Step 2 Difference with original Gauss image and Save in proper location
    lapPyr(minRow:maxRow, minCol:maxCol) = lapPyr(minRow:maxRow, minCol:maxCol) - ...
                                            gaussPyr(minRow:maxRow, minCol:maxCol);
    currDimRows = currDimRows*2;
    currDimCols = currDimCols*2;
    currIter = currIter - 1;
end

% Move values to the range 0-255
lapPyr = lapPyr + 128;

% Copy back the 8x8 gauss image (because on previous line, it becomes white)
lapPyr(allRowStarts(end-1):allRowStarts(end),imgDims(2)+1:imgDims(2)+9) = ...
gaussPyr(allRowStarts(end-1):allRowStarts(end),imgDims(2)+1:imgDims(2)+9);

subplot(1,2,2),imshow(uint8(lapPyr));
title('Laplacian pyramid')
