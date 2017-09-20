
function [stack_allm,varargout]=torax_segmentation(stack_all,database,varargin)

% This function will incorporate the 3D gabor segmentation of the torax.
% For the moment in just make a coarse segmentation looking for the middle
% point in the chest.

if strcmp(database,'DCE-MRI')
    endslice=40;    % 40 is a good value in DCE-MRI database
    minslice=175;   % 175 is a good value for DCE-MRI database
    maxslice=185;   % 185 is a good value for DCE-MRI database
    maxval=1;       % 1 is a good value
    
elseif strcmp(database,'NME')
    stack_all=flip(permute(stack_all,[1 2 4 3]),3);
    endslice=4;    %  is a good value in NME database
    minslice=95;   %  is a good value for NME database
    maxslice=100;   %  is a good value for NME database
    maxval=10;
end

mimg=mean(stack_all);
mimg=squeeze(mimg)/max(mimg(:));
mimgsag=squeeze(mean(mimg(minslice:maxslice,:,:)));
a=sum(mimgsag,2);
chest_midpoint=find(a>maxval,1,'last');
stack_allm=stack_all(:,:,chest_midpoint:end-endslice,:);
if nargin>2
    % apply the same processing to other images
    for i=1:nargin-2
        stp=varargin{i};
        stpm=stp(:,:,chest_midpoint:end-endslice,:);
        varargout{i}=stpm;
    end
end
end