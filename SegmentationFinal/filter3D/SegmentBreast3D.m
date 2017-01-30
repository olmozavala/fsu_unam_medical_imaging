function [ mask,OutputCoordL, OutputCoordR ] = SegmentBreast3D( imgData )


[~, mask]=get_mask(imgData,Th);

[ EM ] = EdgeMap3D(imgData,~mask);

SE=strel('disk',1,0);

EM_eroded=imerode((EM>0),SE);

EMC2=bwareaopen(EM_eroded,10);

CC=bwconncomp(EMC2);




end

