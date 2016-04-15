function [hr hg hb] = oz_allhist(img)
% OZ_ALLHIST Is a function computes the histogram of an image in RGB

    hr = oz_hist(img(:,:,1));
    hg = oz_hist(img(:,:,2));
    hb = oz_hist(img(:,:,3));
