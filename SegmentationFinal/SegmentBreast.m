function [ Final ] = SegmentBreast( niiPath )



%% Start Timer
tic
%% Load the Image Data
addpath('/Users/macbookpro/PhD/Matlab/niiReader/NIfTI_20140122')
nii=load_nii(niiPath);
imgData= nii.img;
DataSize = size (imgData) ;
nimages= DataSize(3);

%% Preprocess All Data. 
% Remove noise from image with gaussian
disp('Preprocess Image for Noise')
%tic
for x = 1:nimages;
    imgData(:,:,x) = medfilt2(imgData(:,:,x), [3 3]);
end
%toc

% for x = 1:nimages; 
%     imshow(imgData(:,:,x),[])
%     pause(0.01)
% end
%% Load The EdgeMap
disp('Get the Edge map of the image')
%tic
% try
%    EMfile=load('EdgeMap.Mat');
%    EdgeMaps = EMfile.EM;
% catch exception
%    EdgeMaps = GetEm3D;
% end
EdgeMaps = GetEm3D;


% for x = 1:nimages; 
%     imshow(EdgeMaps(:,:,x),[])
%     pause(0.01)
% end
%%% Load the Erorded EdgeMap-------------------------------
% try
%    EMfile=load('ErodedEdgeMap.Mat');
%    EdgeMapsEroded = EMfile.EdgeMapEroded;
% catch exception
%    EdgeMapsEroded = getEMeroded3D(EdgeMaps);
% end
EdgeMapsEroded = getEMeroded3D(EdgeMaps);
%toc
% for x = 1:nimages; 
%     imshow(EdgeMapsEroded(:,:,x),[])
%     pause(0.01)
% end
%% ------------------- PROCESS MIDDLE SLICE-------------------------
% First we process the middle slice to determine body landmarks 
% the landmarks are used to define the ROI to project to all the slices
disp('Process Middle Slice to get ROI')
%tic
%%% Get Middle Slice Image-------------------------------------
imageIdx = floor(nimages/2);
img = imgData(:,:,imageIdx);
imageSize = size(img);
numRows = imageSize(1);
numCols = imageSize(2);
% imshow(img,[])
% title('Original Image')
% waitforbuttonpres

%%% Get the Edge Map for middle slice -------------------------------------
EdgeMap=EdgeMaps(:,:,imageIdx);
%  imshow(EM,[])
%   title('Edge Map')
%  waitforbuttonpress
%%% Get the body Fat Mask for middle slice -------------------------------------

% try
%    bodyfatmaskfile=load('mSliceBodyFat.Mat');
%    bodyfatmask = bodyfatmaskfile.bodyfatmask;
% catch exception
%     bodyfatmask = fcm_image(img);
%     save('mSliceBodyFat','bodyfatmask');
% end

bodyfatmask = fcm_image(img);

% imshow(bodyfatmask,[]); 
% title('Body Fat Mask Cluster')
% waitforbuttonpress

%%% Intersect body fat and edge map -------------------------------------
%%% image to store identified edges that intersect the 
%%% body fat mask
detectedEdes = zeros(numRows,numCols);
[B,L] = bwboundaries(EdgeMap,'noholes');
for k = 1:length(B)
   idx = find(L==k);
   mask = zeros(numRows,numCols);
   mask(idx)=1;
   ninter = 50; % number of required intersected pixels
   if(sum(sum(mask.*bodyfatmask))>ninter)
       detectedEdes = detectedEdes + mask;
   end
end
% imshow(detectedEdes,[]); 
% title('Detected Edges')
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
%%% Body Landmarks that define ROI -------------------------------------
[ PPrimaL, PPrimaR, PM] = body_landmarks(detectedEdes);
%%% Project roi to all the images: -------------------------------------
imgDataROI = imgData(PPrimaL(2):PPrimaR(2),PPrimaR(1):numCols,:);
EdgeMapsROI = EdgeMaps(PPrimaL(2):PPrimaR(2),PPrimaR(1):numCols,:);
EdgeMapsErodedROI = EdgeMapsEroded(PPrimaL(2):PPrimaR(2),PPrimaR(1):numCols,:);
% for x = 1:nimages; 
%     imshow(EdgeMapsErodedROI(:,:,x),[])
%     pause(0.01)
% end

%%% recalculate middle point in roi and new image dimensions
imageSize = size(imgDataROI);
numRows = imageSize(1);
numCols = imageSize(2);

PM(1) = PM(1) - PPrimaL(1);
PM(2) = PM(2) - PPrimaL(2);
PPrimaL = [1, 1];
PPrimaR = [1, numRows];

% for x = 1:nimages; 
%     imshow(imgDataROI(:,:,x),[])
%     hold on
%     scatter([PPrimaL(1) PPrimaR(1) PM(1)],[PPrimaL(2) PPrimaR(2) PM(2)],'r')
%     hold off
%     waitforbuttonpress
% end
%toc
%% Get all the BodyFat Maks withn ROI
disp('Getting All the Body Fat')
%tic
% try
%    BodyFatMaskFile=load('BodyFatMask.Mat');
%    BodyFatMasksROI = BodyFatMaskFile.BodyFat3D;
% catch exception
%    BodyFatMasksROI=fcm_image3D(imgDataROI);
% end
BodyFatMasksROI=fcm_image3D(imgDataROI);
%toc
%% ----------------------Select Initial Slice---------------------
disp('Get Initial slice for interior border')
%tic
%%% Get the max area element in the BodyFatMask ROI ---------
SE = strel('disk',1,0);
aproxLim = nimages/2;
for x = 1:aproxLim; 
    im = BodyFatMasksROI(:,:,x); 
    imsize = size(im);
    im = imopen(im,SE);
    im = imclose(im,SE);
    im = bwconncomp(im, 4);
    s = regionprops(im, 'Area', 'PixelList');
    [~,ind] = max([s.Area]);
    pix = sub2ind(imsize, s(ind).PixelList(:,2), s(ind).PixelList(:,1));
    out = zeros(imsize);
    out(pix) = 1;   
    BodyFatMasksROI(:,:,x) = out;    
end

% 
% for x = 1:aproxLim; 
%     imshow(BodyFatMasksROI(:,:,x),[])
%     waitforbuttonpress
%     pause(0.01)
%     disp(x)
% end
% % 
% imshow(BodyFatMasksROI(:,:,1),[])
% title('Initial Slice')
% waitforbuttonpress

%%% Anterior border Body Fat Mask------------------------------
%%% get the posterior border o the maximun 
%%% area element in the body fat mask. 

atBorder = aproxPosteriorBorder(BodyFatMasksROI);
%  for x = 1:aproxLim; 
%      imshow(atBorder(:,:,x),[])
%      waitforbuttonpress
%      disp(x)
%  end

%%% APROXIMATE PARABOLA FOR CHEST LIMIT ----------------------

%%% PARABOLA PARAMETERS
p = polyfit([PPrimaL(2) PPrimaR(2) PM(2)],[PPrimaL(1) PPrimaR(1) PM(1)],2);
xfit =1:numRows;
yfit = polyval(p,xfit);

% figure
% hold on
% scatter([PPrimaL(2) PPrimaR(2) PM(2)],[PPrimaL(1) PPrimaR(1) PM(1)],'r')
% plot(x,y)
% hold off
% waitforbuttonpress

%%% finally get the initial slice index -------------------
error = zeros(1,nimages/2);
for x = 1:nimages/2; 
    img = atBorder(:,:,x);
    index = find(img); % find the coordinates of the approximate border
    [I,J] = ind2sub(size(img),index);
    index = find(J~=1); % remove Noise Coordinates. 
    I=I(index);
    J=J(index);    
    % get the values form the template x, y:
    xq = transpose(xfit(I));
    yq = transpose(yfit(I));
    
    error(x) = immse(yq,J);
%     disp(x);
%     disp(error(x));
%     plot(I,J,'*');
%     hold on
%     plot(xq,yq,'o');
%     axis([1 324 1 196])
%     hold off    
%     waitforbuttonpress

end
[np, InitialSlice] = min(error);


%%% une todos los puntos de la mascara
tube = atBorder(:,:,InitialSlice);
tube = JoinPoints(tube);
% figure('name','Edited Image'),imshow(tube);
% waitforbuttonpress

%toc

%% -------------------GET ALL THE INTERNAL BORDERS------------------- 
disp('Get All internal borders based on initial slice')
%tic
% try
%    InternalBoderFile=load('InternalBorder.Mat');
%    InternalBoder = InternalBoderFile.tubes;
% catch exception
%    InternalBoder = getInternalBorder( EdgeMapsErodedROI, tube, InitialSlice);
% end
InternalBoder = getInternalBorder( EdgeMapsErodedROI, tube, InitialSlice);
%toc
% for x = 1:nimages;
%     imshow(InternalBoder(:,:,x),[])
%     pause(0.01)
% end

%% ------------------- Get All Breast-Skin Border-------------------------
disp('Get skin border for the whole image')
%tic
% try
%    BreasSkinBorderfile=load('SkinBorder.Mat');
%    BreasSkinBorder = BreasSkinBorderfile.ChestContour;
% catch exception
%    BreasSkinBorder = GetChestContour3D( imgDataROI,EdgeMapsROI,BodyFatMasksROI );
% end
BreasSkinBorder = GetChestContour3D( imgDataROI,EdgeMapsROI,BodyFatMasksROI );
%toc
% for x = 1:nimages; 
%     imshow(BreasSkinBorder(:,:,x),[])
%     pause(0.04)
% end


%% Get the Mask
%FinalBorder = logical(bitor(BreasSkinBorder , InternalBoder));
mask = zeros(size(BreasSkinBorder));
for x = 1:nimages; 
    [I1,J1] = ind2sub(imageSize,find(InternalBoder(:,:,x)));
    id1 = sortrows([I1 J1]);
    [I2,J2] = ind2sub(imageSize,find(BreasSkinBorder(:,:,x)));
    id2 = flip(sortrows([I2 J2]));
    id = [id1; id2]; 
    mask(:,:,x) = roipoly(BreasSkinBorder(:,:,x),id(:,2),id(:,1));
end

%% Get Final result
Final=mask.*imgDataROI;
%% Show final result
% for x = 1:nimages; 
%      imshow(mask(:,:,x).*imgDataROI(:,:,x),[])
%      pause(0.04)
% end


%% Stop Timer
toc




end

