function [res]=eigenbreast(stack_all)
% This function applies an extraction of eign breast to a DCE-MRI image
% Returns a structure with the Eign Left Breast, the Eign Right Breast 
% and both Eigh breast together. 
% stack_all
%        = 4D array where the first dimmension is a temporal index and
%          the other 3 dimensions are the regular volume indexes of the
%          Image


%% SETTINGS
% Manually fixed parameters
endslice=40;    % 40 is a good value in DCE-MRI database
minvalue=2;     % value of intensity. below this value, all intensities are saturated to this
maxvalue= 100;  % Value of intensity. Above this value, all intensities are saturated to this (150 is good value in DCE-MRI database).
gaussianS=7;
gaussianD=2;

%% PREPROCESSING 
% Torax segmentation
[breastRoi]=torax_segmentation(stack_all);
stack_allm=stack_all(:,:,breastRoi:end-endslice,:);
 
clear stack_all
% Intensity normalization
stack_allm(stack_allm<=minvalue)=0;        % low value intensity normalization
stack_allm(stack_allm>=maxvalue)=maxvalue; % high value intensity saturation
stack_allm=stack_allm/maxvalue;            % Range between 1 and 0 

% Spatial smoothing
[s1, s2, ~, ~]= size(stack_allm);
midvalue=floor(s2/2);

%Split the image in two asuming simetry: 
stack_allR=stack_allm(:,midvalue+1:end,:,:); % Right breast
stack_allL=stack_allm(:,1:midvalue,:,:);     % Left breast

smoothedR=zeros(size(stack_allR));
smoothedL=zeros(size(stack_allL));
for i=1:s1, 
    smoothedR(i,:,:,:)=smooth3(squeeze(stack_allR(i,:,:,:)),'gaussian',gaussianS,gaussianD); 
    smoothedL(i,:,:,:)=smooth3(squeeze(stack_allL(i,:,:,:)),'gaussian',gaussianS,gaussianD); 
end
 
%% EIGENBREAST EXTRACTION
stack_allm(:,midvalue+1:end,:,:)=smoothedR;
stack_allm(:,1:midvalue,:,:)=smoothedL;

clear stack_allR
clear stack_allL

try [eign,pca]=eigenbrain_extractor(stack_allm,'ica');catch, eign=[]; pca=[]; end
try [eignR,pcaR]=eigenbrain_extractor(smoothedR,'ica'); catch, eignR=[]; pcaR=[]; end
try [eignL,pcaL]=eigenbrain_extractor(smoothedL,'ica'); catch, eignL=[]; pcaL=[]; end

res(1).eign=eignR;
res(2).eign=eignL;
res(1).pca=pcaR;
res(2).pca=pcaL;

res(3).eign=eign;
res(3).pca=pca;

end

function [local]=torax_segmentation(stack_all)
mimg=mean(stack_all);
mimg=squeeze(mimg)/max(mimg(:));
mimgsag=squeeze(mean(mimg(175:185,:,:)));
a=sum(mimgsag,2);
local=find(a>1,1,'last');
end
