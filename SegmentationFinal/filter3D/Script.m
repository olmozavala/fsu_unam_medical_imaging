clc
clear 
close all

% Definitions
patientData = 'D:\DataBases\Breast\DCE-MRI\0232016_p12_too_small_not_visible.mat';
load(patientData);

%Get the first image of the patient. 
MRI = squeeze(stack_all(1,:,:,:));

%-----------------------------------------------------------------
tic
Angle1 = zeros(size(MRI));
Mask1 = zeros(size(MRI));
h = waitbar(0,'Getting Angle 1');
steps = size(MRI,3);
for step = 1:steps
    slc = squeeze(MRI(:,:,step));
    %normalize image
    blksze = 16; thresh = 0.1;
    [normim, mask] = ridgesegment(slc, blksze, thresh);
    Mask1(:,:,step)=mask;
    %Get angles
    Angle1(:,:,step)=ridgeorient(normim, 1, 5,5);    
    waitbar(step / steps)
end
close(h) 


%-----------------------------------------------------------------
Angle2 = zeros(size(MRI));
Mask2 = zeros(size(MRI));
h = waitbar(0,'Getting Angle 1');
steps =size(MRI,1);
for step = 1:size(MRI,1)
    slc = squeeze(MRI(step,:,:));
    %normalize image
    blksze = 16; thresh = 0.1;
    [normim, mask] = ridgesegment(slc, blksze, thresh);
    Mask2(step,:,:)=mask;
    %Get angles
    Angle2(step,:,:)=ridgeorient(normim, 1, 5,5);
    waitbar(step / steps)
end
close(h) 
toc
plotridgeorient(squeeze(Angle1(:,:,120)),10,squeeze(MRI(:,:,120)),1);
plotridgeorient(squeeze(Angle2(120,:,:)),10,squeeze(MRI(120,:,:)),2);
%bmp_stack(Angle2(1:5:end,:,:),10)
