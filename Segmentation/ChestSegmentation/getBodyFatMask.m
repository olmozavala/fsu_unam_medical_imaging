function [ BodyfatMask ] = getBodyFatMask(img)
%img = imgaussfilt(img,2);
%img = medfilt2(img, [5 5]);

clusterNum = 3;
[ Unow, center, now_obj_fcn ] = FCMforImage( img, clusterNum );
bodyfastmaskIndex = -1;
temp = 0; % to hold max zeros count in matrix
values = 0;
for i=1:clusterNum
    cluster = Unow(:,:,i);
    %%Display Clster
    %imshow(cluster);
    %title('Cluser');
    %waitforbuttonpress
    
    cluster = im2bw(cluster,0.5);
    cluster = cluster.*img;
    values=sum(cluster(:));
    if(values>temp)
        temp = values;
        bodyfastmaskIndex=i;
    end
end

BodyfatMask = Unow(:,:,bodyfastmaskIndex);
BodyfatMask = im2bw(BodyfatMask,0.67);
%imshow(BodyfatMask,[]);
%waitforbuttonpress

end

