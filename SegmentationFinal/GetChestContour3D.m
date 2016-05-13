function [ ChestContour ] = GetChestContour3D( imgDataROI,EdgeMapsROI,BodyFatMasksROI )
%UNTITLED30 Summary of this function goes here
%   Detailed explanation goes here

waitBar = waitbar(0,'Please wait...');
DataSize = size (imgDataROI) ;
nImages = DataSize(3);
steps = nImages;
ChestContour = zeros(DataSize);
for x = 1:nImages;
    %% Get slice Image
    img = imgDataROI(:,:,x);
    % imshow(img,[]); 
    % title('ROI')
    % waitforbuttonpress
    %% Get the ROI Edge Map
    EdgeMap=EdgeMapsROI(:,:,x);
    % imshow(EM,[])
    % waitforbuttonpress
    % title('Edge Map')
    %% Get the ROI body Fat Mask
    %bodyfatmask = fcm_image(img);
    bodyfatmask = BodyFatMasksROI(:,:,x);
    % imshow(bodyfatmask,[]); 
    % title('Body Fat Mask Cluster')
    % waitforbuttonpress    
    
    ChestContour(:,:,x) = GetChestContour(img,EdgeMap,bodyfatmask);
    
    %% publish Result
    waitbar(x / steps);
end
close(waitBar)

save('SkinBorder.Mat','ChestContour');

end

