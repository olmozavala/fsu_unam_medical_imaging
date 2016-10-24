% RIDGEORIENT - Estimates the local orientation of ridges in a fingerprint
%
% Usage:  [orientim, reliability, coherence] = ridgeorientation(im, gradientsigma,...
%                                             blocksigma, ...
%                                             orientsmoothsigma)
%
% Arguments:  im                - A normalised input image.
%             gradientsigma     - Sigma of the derivative of Gaussian
%                                 used to compute image gradients.
%             blocksigma        - Sigma of the Gaussian weighting used to
%                                 sum the gradient moments.
%             orientsmoothsigma - Sigma of the Gaussian used to smooth
%                                 the final orientation vector field. 
%                                 Optional: if ommitted it defaults to 0

function [angle1, angle2] = ...
             ridgeorient3D(im, gradientsigma, blocksigma, orientsmoothsigma)
        
    if ~exist('orientsmoothsigma', 'var'), orientsmoothsigma = 0; end
    
    % Calculate image gradients.
    sze = fix(6*gradientsigma);   if ~mod(sze,2); sze = sze+1; end

    f = images.internal.createGaussianKernel([gradientsigma gradientsigma gradientsigma],[sze sze sze]); % Generate Gaussian filter.
    [fx,fy,fz] = gradient(f);          
    
    % Gradient of Gausian.
    Gx = imfilter(im, fx);
    Gy = imfilter(im, fy);
    Gz = imfilter(im, fz);

    angle1 = getAngleField(Gx, Gy, blocksigma, orientsmoothsigma);
    angle2 = getAngleField(hypot(Gx,Gy), Gz, blocksigma, orientsmoothsigma);


function [orientim] = ...
             getAngleField(Gx, Gy, blocksigma, orientsmoothsigma)
    % Estimate the local ridge orientation at each point by finding the
    % principal axis of variation in the image gradients.
   
    Gxx = Gx.^2;       % Covariance data for the image gradients
    Gxy = Gx.*Gy;
    Gyy = Gy.^2;
    
    % Now smooth the covariance data to perform a weighted summation of the
    % data.
    sze = fix(6*blocksigma);   if ~mod(sze,2); sze = sze+1; end    
    f = images.internal.createGaussianKernel([blocksigma blocksigma blocksigma], [sze sze sze]);
  

    Gxx=imfilter(Gxx, f );
    Gxy=2*imfilter(Gxy,f);
    Gyy=imfilter(Gyy, f);   
    
    % Analytic solution of principal direction
    denom = sqrt(Gxy.^2 + (Gxx - Gyy).^2) + eps;
    sin2theta = Gxy./denom;            % Sine and cosine of doubled angles
    cos2theta = (Gxx-Gyy)./denom;

    if orientsmoothsigma
        sze = fix(6*orientsmoothsigma);   if ~mod(sze,2); sze = sze+1; end    

        f = images.internal.createGaussianKernel([orientsmoothsigma orientsmoothsigma orientsmoothsigma], [sze sze sze]);
        cos2theta=imfilter(cos2theta, f);
        sin2theta=imfilter(cos2theta, f);           
    end
    
    orientim = pi/2 + atan2(sin2theta,cos2theta)/2;
         

