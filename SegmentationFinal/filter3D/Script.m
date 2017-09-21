clc
clear 
close all
run('/home/ialvarezillan/fsu_unam_medical_imaging/Paths/setMyPathBreast.m')
% Definitions (it assumes the function setMypath has been executed, and the
% DCE-MRI database is in the path

patientData ={'2004235_p9_ok.mat' '3141148_p8_ok_huge_tumor' '6107252_p2_ok' '3329368_p3_ok' '3027642_p4_ok_two_tumors'};

for i=1:5
load(patientData{i});

% The DCE-MRI is orientated in a different way that the NME database, so a reorientation is needed first 
stp=flip(permute(stack_all,[1 2 4 3]),4);

%Get the first image of the patient, and reduce the resolution by interpolation. (It is not necessary but it will be faster) 
stp_reduced=reduce_interp(stp,3);
mean_img = squeeze(stp_reduced(1,:,:,:));%squeeze(mean(stp_reduced));%

%Get a mask that discards the background
%mask=zeros(size(mean_img));
%[~, mask]=get_mask(stp_reduced);

%filter image to remove noise
filt_img=medfilt3(mean_img);

%get the segmentation mask 
k = 10 ;
medfreq=1.2;
border=3;
proportion=0.2;
dil_size=8;
angleInc=3;
[segmented_mask] = SegmentBreast3D( filt_img , k , medfreq , border, proportion , dil_size ,angleInc);

%plot results
bmp_stack(mean_img);
segmented_data=zeros(size(stp_reduced));
segmented_data(:,segmented_mask)=stp_reduced(:,segmented_mask);
bmp_stack(segmented_data);
bmp_stack(segmented_data(1,:,:,:));
end