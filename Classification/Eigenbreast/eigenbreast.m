function [res]=eigenbreast(stack_all)
%% SETTINGS


% Manually fixed parameters

endslice=40;  % 40 is a good value in DCE-MRI database
minvalue=2;   %
maxvalue= 100; % Value of intensity. Above this value, all intensities are saturated to this (150 is good value in DCE-MRI database).
%local=1;
gaussianS=7;
gaussianD=2;


%% PREPROCESSING 

% Torax segmentation
[local]=torax_segmentation(stack_all);
stack_allm=stack_all(:,:,local:end-endslice,:);
 
clear stack_all
% Intensity normalization
stack_allm(stack_allm<=minvalue)=0;        % low value intensity normalization
stack_allm(stack_allm>=maxvalue)=maxvalue; % high value intensity saturation
stack_allm=stack_allm/maxvalue;            % Range between 1 and 0 

% Spatial smoothing
[s1 s2 s3 s4]= size(stack_allm);
midvalue=floor(s2/2);
stack_allR=stack_allm(:,midvalue+1:end,:,:); % Right breast
stack_allL=stack_allm(:,1:midvalue,:,:);     % Left breast

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
%level=graythresh(squeeze(mean(mimg(:,:,end-3:end),3)));
%imint=im2bw(mimg(:,:,end-2),level);
% se=strel('disk',10);
% imintcl=imclose(imint,se);
% BW=imfill(imintcl,'holes');
% for i=1:170
% for j=1:5
% im=squeeze(stack_all(j,:,:,i));
% im(BW)=0;
% stack_allm(j,:,:,i)=im;
% end
% end
mimgsag=squeeze(mean(mimg(175:185,:,:)));
a=sum(mimgsag,2);
local=find(a>1,1,'last');%[~,local]=max(a);
end
