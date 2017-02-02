function [propdiff,obsiz_list,EM_eroded]=erode_intwo(EM,SE)

EM_eroded=imerode((EM>0),SE);

% Detect the biggest separated parts to remove the interior organs
CC=bwconncomp(EM_eroded);

for n=1:CC.NumObjects
ordsiz(n)=numel(CC.PixelIdxList{n});
end

obsiz_list=sort(ordsiz,'descend');

% Remove the second biggest object detected, together with all
% the smaller ones (with the hope that everything but the chest contour is
% removed) 
csumbo=cumsum(obsiz_list);
propcst=(csumbo(1:end))/csumbo(end)*100;
propdiff= -propcst(1:end-1)+propcst(2:end);
end