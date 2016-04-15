%%% This function upsamples an image. In the future it will allow for multiple methods for upsampling.
function [upImg] = oz_upsample(img,method)

dims = size(img);
upImg = zeros(dims(1)*2,dims(2)*2);

switch method
    case 'simplest'
        for row=1:dims(1)
            for col=1:dims(2)
                upImg(row*2-1:row*2,col*2-1:col*2) = img(row,col);
            end
        end
end

