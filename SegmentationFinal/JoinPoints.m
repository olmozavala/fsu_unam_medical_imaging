function [ output ] = JoinPoints( tube )
%UNTITLED40 this function join the white points in binary image

%%% une todos los puntos de la mascara
index = find(tube); % find the coordinates of the approximate border
[I, J] = ind2sub(size(tube),index);

%%% Sort elements
indexes = [I J];
indexes = sortrows(indexes);
I = indexes(:,1);
J = indexes(:,2);
ncords = length(J);
indx(1:2:ncords*2) = J;
indx(2:2:ncords*2) = I;
indx = int32(indx);

%// NEW CODE
tube = im2uint8(tube);

%// YOUR CODE FROM BEFORE
%shapeInserter = vision.ShapeInserter('Shape','Rectangles','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));
%rect = int16([10, 10, 100, 100]);

shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','White');

rgb = repmat(tube, [1, 1, 3]);
output = step(shapeInserter, rgb, indx);
output = im2bw(output,0.5);
end

