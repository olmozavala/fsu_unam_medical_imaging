%% This function computes the histogram of grayscale image
% bins is the total of bins we want to use (256 by default)
% minval is the minimum range to use
% maxval is the maximum range to use

function [h] = oz_hist(grayImg, bins, minval, maxval)
    % Obtain width and height of the image
    [rows cols] = size(grayImg);

    % Size of histogram
    if (~exist('bins', 'var'))
        bins = 256;

        % Initialize the histogram
        h = zeros(bins,1);

        % Initialize the histogram
        for idx=1:rows*cols
            h(grayImg(idx)+1) = h(grayImg(idx)+1) + 1;
        end

    else

        % Range for each bin
        if (~exist('minval', 'var'))
            minval = 0;
        end
        if (~exist('maxval', 'var'))
            maxval = 256;
        end

        % Set the range
        binSize = (maxval-minval)/bins;
        ranges = [minval: binSize : maxval];
        rangesUp = ranges-1;

        % Initialize the histogram
        h = zeros(bins,1);

        % Doing it by indices
        for idx=1:rows*cols
            histIdx = find( ranges >= grayImg(idx) & rangesUp < grayImg(idx));
            if(histIdx > 0)
                h(histIdx) = h(histIdx) + 1;
            end
        end
    end

