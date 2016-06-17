function [ EM ] = EdgeMap(im)
    % Identify ridge-like regions and normalise image
    blksze = 16; thresh = 0.05;
    [normim, mask] = ridgesegment(im, blksze, thresh);
    %show(normim,1);
    
    % Determine ridge orientations
    [orientim, reliability] = ridgeorient(normim, 1, 5, 5);
    
    %orientim=repmat(pi/size(im,1):pi/size(im,1):pi,[size(im,2) 1])';
    %plotridgeorient(orientim, 20, im, 2)
    %show(reliability,6)
    
    % Determine ridge frequency values across the image
    blksze = 36; 
    [freq, medfreq] = ridgefreq(normim, mask, orientim, blksze, 5, 5, 15);
    %show(freq,3) 
    
    % Actually I find the median frequency value used across the whole
    % fingerprint gives a more satisfactory result...
    freq = medfreq.*mask;
    
    % Now apply filters to enhance the ridge pattern
    newim = ridgefilter(normim, orientim, freq, 0.35, 0.75, 1);
    %show(newim,4);
    
    % Binarise, ridge/valley threshold is 0
    %EM = newim > 200;
    %show(EM,5);
    EM=newim;


end

