function [ newim ] = EdgeMap3D(im,k,medfreq,filter,angleInc)

    if nargin<4
        medfreq=0.4; 
        if nargin<3
            k=0.5;
        end
    end
    % Identify ridge-like regions and normalise image
    normim = normalise(im,0,1);  % normalise to have zero mean, unit std dev
    
        
    % Renormalise image so that the *ridge regions* have zero mean, unit
    % standard deviation.
%     im = im - mean(im(:));
%     normim = im/std(im(:));    
    
    % Determine ridge orientations
    gradientsigma=1; 
    blocksigma=round(size(im,1)/40); % This is a good trade-off between computation time and accuracy. Changes in here may not have a dramatic effect.
   
    [orientim1, orientim2] = ridgeorient3D(normim,gradientsigma, blocksigma, blocksigma);
    
    fprintf('Orientation maps extracted!\n')    
    
    % Now apply filters to enhance the ridge pattern
    newim = ridgefilter3D(normim, orientim1,orientim2, medfreq,filter,k,angleInc);
    


end

