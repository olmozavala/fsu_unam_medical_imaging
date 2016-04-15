%% This function computes the comulative distribution function of an image histogram (size 256)
function [cd] = oz_cumdist(h)
    sizeh = length(h);
    cd = zeros(sizeh,1);
    total = sum(h);% Sum of values inside the hist

    cd(1) = h(1)/total;% Initial cd at 0
    for i=2:sizeh
        cd( i ) = cd(i-1) + h(i)/total;
    end
