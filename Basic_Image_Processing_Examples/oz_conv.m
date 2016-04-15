%% This funciton convolves a mask into an image
function convImg = oz_conv(img, mask)

    img = double(img);
    sizeMask = length(mask);
    sizeImg = size(img);
    redSizeBy = floor(sizeMask/2);
    convImg = zeros( sizeImg(1) - redSizeBy, sizeImg(2) - redSizeBy);

    for row=redSizeBy+1:sizeImg(1)-redSizeBy
        for col=redSizeBy+1:sizeImg(2)-redSizeBy
            % Making the convolution for one pixel
            convVal = sum(sum(img(row-redSizeBy:row+redSizeBy, col-redSizeBy:col+redSizeBy).*mask));
            convImg(row-redSizeBy, col-redSizeBy) = convVal;
        end
    end

    convImg = uint8(convImg);
