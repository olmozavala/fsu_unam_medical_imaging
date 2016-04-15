%% This function computes the histogram of an image in RGB

function [hr hg hb] = oz_allhist(img)
    hr = oz_hist(img(:,:,1));
    hg = oz_hist(img(:,:,2));
    hb = oz_hist(img(:,:,3));
