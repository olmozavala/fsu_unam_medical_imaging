function [ filaclos] = SegmentBreast3D( imgData ,mask)

%Get the Edge map
[ EM ] = EdgeMap3D(imgData,mask);

% Erode it to separate the inner organs from the chest
SE=strel('disk',1,0);

EM_eroded=imerode((EM>0),SE);

% Detect the biggest separated parts to remove the interior organs
CC=bwconncomp(EM_eroded);

for n=1:CC.NumObjects
ordsiz(n)=numel(CC.PixelIdxList{n});
end

obsiz_list=sort(ordsiz,'descend');

% Remove the second biggest object detected, together with all
% the smaller ones (with the hope that everything but the chest contour is
% removed
EM_cropped=bwareaopen(EM_eroded,obsiz_list(2)+1);

%fill the holes of the obtained image by morphological closing it first
%and then filling the holes
SE2=strel('disk',10,0);


for i=1:size(EM_cropped,2)
closed=imclose(squeeze(EM_cropped(:,i,:)), SE2);
filled=imfill(closed,'holes');
filaclos(:,i,:)=filled;
end

end

