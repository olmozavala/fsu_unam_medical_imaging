function [ EdgeMapEroded ] = getEMeroded3D( EdgeMaps )
DataSize = size (EdgeMaps) ;
nImages = DataSize(3);
SE = strel('disk',1,0);

waitBar = waitbar(0,'Eroded Edge Map ...');
EdgeMapEroded = zeros(size(EdgeMaps));
for x = 1:nImages; 
    EM = EdgeMaps(:,:,x);
    EMe = imerode(EM,SE);
    EdgeMapEroded(:,:,x) = EM - EMe;
    waitbar(x / nImages);
end
close(waitBar)
save('ErodedEdgeMap','EdgeMapEroded');
end

