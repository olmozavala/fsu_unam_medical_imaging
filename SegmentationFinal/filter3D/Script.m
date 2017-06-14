clc
clear 
close all

% Definitions (it assumes the function setMypath has been executed, and the
% DCE-MRI database is in the path
patientData ='3329368_p3_ok';% '2004235_p9_ok.mat';%
load(patientData);

% The DCE-MRI is orientated in a different way that the NME database, so a reorientation is needed first 
stp=flip(permute(stack_all,[1 2 4 3]),4);

%Get the first image of the pateient, and reduce the resolution by interpolation. (It is not necessary but it will be faster) 
stp_reduced=reduce_interp(stp,3);
img = squeeze(stp_reduced(1,:,:,:));

%Get a mask that discards the background
[~, mask]=get_mask(stp_reduced,0.06);

%get the segmented breast from the chest mask
[segmented_mask] = SegmentBreast3D( img,~mask);

cc=bwconncomp(gt(segmented_mask,0));
for i=1:cc.NumObjects
    mean_val(i)=mean(segmented_mask(cc.PixelIdxList{i}));
end

[~,max_i_val]=max(mean_val);
im=zeros(size(segmented_mask));
im(cc.PixelIdxList{max_i_val})=1;
bmp_stack(im+img/max(img(:)),6,2)