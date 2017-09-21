% RIDGEFILTER - enhances fingerprint image via oriented filters
%
% Function to enhance fingerprint image via oriented filters
%
% Usage:
%  newim =  ridgefilter(im, orientim, freqim, kx, ky, showfilter)
%
% Arguments:
%         im       - Image to be processed.
%         orientim - Ridge orientation image, obtained from RIDGEORIENT.
%         freqim   - Ridge frequency image, obtained from RIDGEFREQ.
%         kx, ky   - Scale factors specifying the filter sigma relative
%                    to the wavelength of the filter.  This is done so
%                    that the shapes of the filters are invariant to the
%                    scale.  kx controls the sigma in the x direction
%                    which is along the filter, and hence controls the
%                    bandwidth of the filter.  ky controls the sigma
%                    across the filter and hence controls the
%                    orientational selectivity of the filter. A value of
%                    0.5 for both kx and ky is a good starting point.
%         showfilter - An optional flag 0/1.  When set an image of the
%                      largest scale filter is displayed for inspection.
%
% Returns:
%         newim    - The enhanced image
%
% See also: RIDGEORIENT, RIDGEFREQ, RIDGESEGMENT

% Reference:
% Hong, L., Wan, Y., and Jain, A. K. Fingerprint image enhancement:
% Algorithm and performance evaluation. IEEE Transactions on Pattern
% Analysis and Machine Intelligence 20, 8 (1998), 777 789.

% Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
%
% January 2005

function newim = ridgefilter3D(im, orient1, orient2, freq,filter,sze,angleInc)



im = double(im);
[rows, cols, slcs] = size(im);
newim = zeros(rows,cols,slcs);

freq=freq.*ones(size(im));
% [validr,validc, valids] = find(freq);  % find where there is valid frequency data.
% ind = sub2ind([rows,cols,slcs], validr, validc,valids);
ind = find(freq(:));
[validr,validc, valids]=ind2sub(size(freq),ind);

% Round the array of frequencies to the nearest 0.01 to reduce the
% number of distinct frequencies we have to deal with.
freq(ind) = round(freq(ind)*100)/100;

% Generate an array of the distinct frequencies present in the array
% freq
unfreq = unique(freq(ind));

% Generate a table, given the frequency value multiplied by 100 to obtain
% an integer index, returns the index within the unfreq array that it
% corresponds to
freqindex = ones(100,1);
for k = 1:length(unfreq)
    freqindex(round(unfreq(k)*100)) = k;
end



% Find indices of matrix points greater than maxsze from the image
% boundary

% maxsze = sze(1);
%  finalind = find(validr>maxsze & validr<rows-maxsze & ...
%      validc>maxsze & validc<cols-maxsze & ...
%      valids>maxsze & valids<slcs-maxsze);
finalind = find(validr & validc & valids);

% Convert orientation matrix values from radians to an index value
% that corresponds to round(degrees/angleInc)
maxorientindex = round(180/angleInc);
orientindex1 = round(orient1/pi*180/angleInc);
orientindex2 = round(orient2/pi*180/angleInc);
i1 = find(orientindex1 < 1);   orientindex1(i1) = orientindex1(i1)+maxorientindex;
i1 = find(orientindex1 > maxorientindex);
orientindex1(i1) = orientindex1(i1)-maxorientindex;
i2 = find(orientindex2 < 1);   orientindex2(i2) = orientindex1(i2)+maxorientindex;
i2 = find(orientindex2 > maxorientindex);
orientindex2(i2) = orientindex2(i2)-maxorientindex;

% Expand the image to filter the image boundary
imn=zeros(size(im,1)+2*sze(1),size(im,2)+2*sze(1),size(im,3)+2*sze(1));
imn(1+sze(1):size(im,1)+sze(1),1+sze(1):size(im,2)+sze(1),1+sze(1):size(im,3)+sze(1)) = im;

% Finally do the filtering


for k = 1:length(finalind)
    r = validr(finalind(k));
    c = validc(finalind(k));
    s = valids(finalind(k));
%    [r,c,s]=ind2sub(size(im),finalind(k));
    
    % find filter corresponding to freq(r,c)
    filterindex = freqindex(round(freq(r,c,s)*100));
    
    t = sze(filterindex);
    newim(r,c,s) = sum(sum(sum(imn(r:r+2*t, c:c+2*t,s:s+2*t).*filter{orientindex1(r,c,s),orientindex2(r,c,s)})));%,filterindex})));
end
end

