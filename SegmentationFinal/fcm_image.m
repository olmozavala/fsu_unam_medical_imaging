function [ imagNew ] = fcm_image(I,Nc)

if nargin<2, Nc=3; end

imageSize = size(I);

% To include the location:
% [Idx,Jdx] = ind2sub([numRows numCols],[1:numRows*numCols]);
% Idx = transpose(Idx);
% Jdx = transpose(Jdx);
% data = [I(:) Idx Jdx]; % data array
data = I(:);
options = [NaN 100 0.001 0];
[~,U,~] = fcm(I(:),Nc,options); % Fuzzy C-means classification with 7 classes

% Finding the pixels for each class
maxU = max(U);
mask(1:numel(data))=0;
for i=1:Nc
index{i} = find(U(i,:) == maxU);
mask(index{i})=i;
end
% index2 = find(U(2,:) == maxU);
% index3 = find(U(3,:) == maxU);
% index = {index1,index2,index3};

%Create the masks of each cluster. 
% mask1(1:length(data),1)=0;
% mask1(index1)= 1;
% mask2(1:length(data),1)=0;  
% mask2(index2)= 1;
% mask3(1:length(data),1)=0;  
% mask3(index3)= 1;



% Get the index:
%[~,Idx] = max([sum(mask1.*data),sum(mask2.*data),sum(mask3.*data)]); % idx: index for area of interest. 

% Assigning pixel to each class by giving them a specific value
%fcmImage(1:length(data))=0;  
%fcmImage(index{Idx})= 1;

% Reshapeing the array to a image
imagNew = reshape(mask,imageSize);


end

