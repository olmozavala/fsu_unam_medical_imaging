function [ EM ] = EdgeMap3D(im,mask)
    % Identify ridge-like regions and normalise image

    im = normalise(im,0,1);  % normalise to have zero mean, unit std dev
    
        
    % Renormalise image so that the *ridge regions* have zero mean, unit
    % standard deviation.
    im = im - mean(im(mask));
    normim = im/std(im(mask));    

    %show(normim,1);
    
    % Determine ridge orientations
    [orientim1, orientim2] = ridgeorient3D(normim, 1, 5, 5);
    
    fprintf('Orientation maps extracted!\n')
    %orientim=repmat(pi/size(im,1):pi/size(im,1):pi,[size(im,2) 1])';
    %plotridgeorient(orientim, 20, im, 2)
    %show(reliability,6)
    
    % Determine ridge frequency values across the image 
    [medfreq] = 0.16;
    %show(freq,3) 
    
    % Actually I find the median frequency value used across the whole
    % fingerprint gives a more satisfactory result...
    freq = medfreq.*mask;
    
    % Now apply filters to enhance the ridge pattern
    newim = ridgefilter3D(normim, orientim1,orientim2, freq, 0.5, 0.5, 0.5);
    %show(newim,4);
    
    % Binarise, ridge/valley threshold is 0
    %EM = newim > 200;
    %show(EM,5);
    EM=newim;


end

