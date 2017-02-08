function [ EM ] = EdgeMap3D(im,mask,k,medfreq)

    if nargin<4
        medfreq=0.4; % Controls the size of the filter. Must be adjusted to the size of the wall you want to detect. A higher value of frequency may produce too many lines
        if nargin<3
            k=0.5;
        end
    end
    % Identify ridge-like regions and normalise image
    im = normalise(im,0,1);  % normalise to have zero mean, unit std dev
    
        
    % Renormalise image so that the *ridge regions* have zero mean, unit
    % standard deviation.
    im = im - mean(im(mask));
    normim = im/std(im(mask));    

    %show(normim,1);
    
    % Determine ridge orientations
    gradientsigma=1; 
    blocksigma=round(size(im,1)/40); % This is a good trade-off between computation time and accuracy. Changes in here may not have a dramatic effect.
   
    [orientim1, orientim2] = ridgeorient3D(normim,gradientsigma, blocksigma, blocksigma);
    
    fprintf('Orientation maps extracted!\n')
    %orientim=repmat(pi/size(im,1):pi/size(im,1):pi,[size(im,2) 1])';
    %plotridgeorient(orientim, 20, im, 2)
    %show(reliability,6)
    

    
    % Actually I find the median frequency value used across the whole
    % fingerprint gives a more satisfactory result...
    freq = medfreq.*mask;
    
    % Now apply filters to enhance the ridge pattern
    newim = ridgefilter3D(normim, orientim1,orientim2, freq, k, k, k);
    %show(newim,4);
    
    % Binarise, ridge/valley threshold is 0
    %EM = newim > 200;
    %show(EM,5);
    EM=newim;


end

