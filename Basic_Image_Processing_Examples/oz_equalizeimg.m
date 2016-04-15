%% This function flattens the histograms of an image
% The return values are a modified image and
% a LUT with corresponding pixel values for each color
function [newChan, lut] = oz_equalizeimg(img, distVal)

    eps = .000001;%Required to avoid round problems
    h = oz_hist(img); % Compute histogram
    cd = oz_cumdist(h); % Comput CD

    % This is the minimum and maximum color that appears on the image
    minidx = min(find(cd > 0));
    maxidx = min(find(cd >= (1 - eps)));

    % New CD that is resized
    % Resizing the CDR (the minimum color shoud be 0
    % and the maximum should be 255)
    ncd = zeros(256,1);
    previdx = 0;
    for i=minidx:maxidx
        newidx = floor(1 +  ((i - minidx)/(maxidx - minidx))*(255));
        ncd(previdx+1:newidx) = cd(i);
        previdx= newidx;
    end

    lut = zeros(256,1);% LUT for specified 
    stepSize = 1/distVal;% Indicates when each dims should stop
    for i=1:distVal
        color = find (ncd > (stepSize*(i-1)) & ncd <= (stepSize*i + eps) );
        lut(color) = floor(mean(color));
    end

    origChan = img;
    newChan = zeros(size(origChan));
    indexes = 1:size(origChan,1)*size(origChan,2);
    newChan(indexes) = lut(origChan(indexes)+1);

