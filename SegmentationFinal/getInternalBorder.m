function [ tubes ] = getInternalBorder( EdgeMapsErodedROI, tube, InitialSlice)
%UNTITLED44 Summary of this function goes here
%   Detailed explanation goes here
SE = strel('disk',3,0);
nimages = size(EdgeMapsErodedROI,3);
tubes = zeros(size(EdgeMapsErodedROI));
tubes(:,:,InitialSlice) = tube;
graphsize = size(EdgeMapsErodedROI,1);
waitBar = waitbar(0,'Border detection inside UP');
for x = InitialSlice+1:nimages;
    tubeDilated = imdilate(tube,SE);
    
    img = 255.*ones(size(tubeDilated));
    img(find(tubeDilated))=150;
    img(find(tubeDilated.* EdgeMapsErodedROI(:,:,x)))=1;

    
    imgGraph = im2graph(img, 8);
    
    [dist, path, pred] = graphshortestpath(imgGraph, 1, graphsize);
    
    newTube = zeros(size(tubeDilated));
    newTube(path) = 1;
%     
%     imshow(img,[])
%     waitforbuttonpress
%     imshow(newTube,[])
%     waitforbuttonpress
%     
    tubes(:,:,x) = newTube;
    tube = newTube;
    waitbar(x / nimages);
end
tube = tubes(:,:,InitialSlice) ;
for x = InitialSlice-1:-1:1;
    tubeDilated = imdilate(tube,SE);
    
    img = 255.*ones(size(tubeDilated));
    img(find(tubeDilated))=150;
    img(find(tubeDilated.* EdgeMapsErodedROI(:,:,x)))=1;
    
    imgGraph = im2graph(img, 8);
    
    [dist, path, pred] = graphshortestpath(imgGraph, 1, graphsize);
    
    newTube = zeros(size(tubeDilated));
    newTube(path) = 1;
    
    
    
    tubes(:,:,x) = newTube;
    tube = newTube;
    waitbar(x / nimages);
end
close(waitBar)
% for x = 1:nimages;
%     imshow(tubes(:,:,x),[])
%     pause(0.01)
% end
save('InternalBorder','tubes');

end

