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

function newim = ridgefilter3D(im, orient1, orient2, freq, kx, ky,kz)



angleInc = 3;  % Fixed angle increment between filter orientations in
% degrees. This should divide evenly into 180

im = double(im);
[rows, cols, slcs] = size(im);
newim = zeros(rows,cols,slcs);

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

% Generate filters corresponding to these distinct frequencies and
% orientations in 'angleInc' increments.

[filter]=filtercreation(unfreq,kx,ky,kz,angleInc);


% Find indices of matrix points greater than maxsze from the image
% boundary
maxsze = sze(1);
 finalind = find(validr>maxsze & validr<rows-maxsze & ...
     validc>maxsze & validc<cols-maxsze & ...
     valids>maxsze & valids<slcs-maxsze);
%finalind = ind(;

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

% Finally do the filtering
for k = 1:length(finalind)
    r = validr(finalind(k));
    c = validc(finalind(k));
    s = valids(finalind(k));
%    [r,c,s]=ind2sub(size(im),finalind(k));
    
    % find filter corresponding to freq(r,c)
    filterindex = freqindex(round(freq(r,c,s)*100));
    
    t = sze(filterindex);
    newim(r,c,s) = sum(sum(sum(im(r-t:r+t, c-t:c+t,s-t:s+t).*filter{orientindex1(r,c,s),orientindex2(r,c,s),filterindex})));
end
end

function [filter]=filtercreation(unfreq,kx,ky,kz,angleInc)
sze = zeros(length(unfreq),1);
filter = cell(length(unfreq),length(unfreq),180/angleInc);
for k = 1:length(unfreq)
    sigmax = 1/unfreq(k)*kx;
    sigmay = 1/unfreq(k)*ky;
    sigmaz = 1/unfreq(k)*kz;
    sze(k) = round(3*max(sigmax,max(sigmay,sigmaz)));
    [x,y,z] = meshgrid(-sze(k):sze(k));
    reffilter = exp(-(x.^2/sigmax^2 + y.^2/sigmay^2 +  z.^2/sigmaz^2)/2)...
        .*cos(2*pi*unfreq(k)*x);
    
    % Generate rotated versions of the filter.  Note orientation
    % image provides orientation *along* the ridges, hence +90
    % degrees, and imrotate requires angles +ve anticlockwise, hence
    % the minus sign.
    filterb=zeros(size(reffilter));
    count=1;
    for o1 = 1:180/angleInc
        for i=1:size(reffilter,3)
            reffilter2D=squeeze(reffilter(:,:,i));
            filterslice = imrotate(reffilter2D,-(o1*angleInc+90),'bilinear','crop');
            filterb(:,:,i)=filterslice;
        end
        if count>10, fprintf('.'); count=1; end
            
        for o2=1:180/angleInc
            for i=1:size(reffilter,1)
                reffilter2D=squeeze(filterb(i,:,:));
                filterslice = imrotate(reffilter2D,(o2*angleInc),'bilinear','crop');
                filterbr(i,:,:)=filterslice;
            end
            filter{o1,o2,k}=filterbr;
        end
        count=count+1;
    end
end
fprintf('3D filter created\n')
end