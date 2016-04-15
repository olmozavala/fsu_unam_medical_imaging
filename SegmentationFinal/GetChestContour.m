function [ OuterBin2 ] = GetChestContour(img,EdgeMap,bodyfatmask)
%% Get Image Parameters
%imageIdx=10;
%img = imgDataROI(:,:,imageIdx);
imageSize = size(img);
numRows = imageSize(1);
numCols = imageSize(2);
% imshow(img,[]); 
% title('ROI')
% waitforbuttonpress
%% Intersect body fat and edge map
%%% image to store identified edges that intersect the 
%%% body fat mask
detectedEdes = zeros(numRows,numCols);
[B,L] = bwboundaries(EdgeMap,'noholes');
ninter = 100; % number of required intersected pixels
for k = 1:length(B)
   idx = L==k;
   mask = zeros(numRows,numCols);
   mask(idx)=1;   
   if(sum(sum(mask.*bodyfatmask))>ninter)
       detectedEdes = detectedEdes + mask;
   end
end

% imshow(detectedEdes,[]);
% title('Body Contour Edges')
% waitforbuttonpress

SE = strel('disk',3,0);
detectedEdes = imdilate(detectedEdes, SE);
% imshow(detectedEdes,[]); 
% title('Body Fat Mask - Dilate')
% waitforbuttonpress
detectedEdes = imfill(detectedEdes, 'holes');
% imshow(detectedEdes,[]); 
% title('Body Fat Mask - Fill')
% waitforbuttonpress
detectedEdes = imerode(detectedEdes, SE);
%  imshow(detectedEdes,[]); 
%  title('Body Fat Mask - Erode')
%  waitforbuttonpress
%% Body contour
% Get the boundaries of the mask
[B, L] = bwboundaries(detectedEdes,'noholes');
% get the outer most boundary
[~, OuterIndex]=max(cellfun(@numel,B));
OuterBoundary = B{OuterIndex};

% create image of the contour
OuterBin = zeros(numRows,numCols);
idx = sub2ind([numRows numCols], OuterBoundary(:,1), OuterBoundary(:,2));
OuterBin(idx)=1;
% imshow(OuterBin,[]); 
% title('Boundary alone')
% waitforbuttonpress

% get the anterior part of the contour. 
OuterBin2 = zeros(numRows,numCols);
for R=1:numRows
    for C=numCols:-1:1
        if(OuterBin(R,C)==1)
            OuterBin2(R,C)=1;
            break
        end
    end
end

%Join Points in contour
OuterBin2 = JoinPoints(OuterBin2);


% imshow(OuterBin2,[]); 
% title('Boundary alone')
% waitforbuttonpress

%GetChestContour( imgData,EdgeMaps,30,PPrimaL, PPrimaR);


end

