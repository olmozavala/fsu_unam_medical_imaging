function [ newim ] = EdgeMap3D(im,mask,k,medfreq,filter,angleInc)

    if nargin<4
        medfreq=0.4; 
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
    
    % Determine ridge orientations
    gradientsigma=1; 
    blocksigma=round(size(im,1)/40); % This is a good trade-off between computation time and accuracy. Changes in here may not have a dramatic effect.
   
    [orientim1, orientim2] = ridgeorient3D(normim,gradientsigma, blocksigma, blocksigma);
    
    fprintf('Orientation maps extracted!\n')    

    freq = medfreq.*mask;
    
    % Now apply filters to enhance the ridge pattern
    newim = ridgefilter3D(normim, orientim1,orientim2, freq,filter,k,angleInc);
    


end

