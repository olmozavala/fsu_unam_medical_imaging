function [cont_clean]=GetChestContour(imgData,sph_size,pix_removal)

% Gets the chest contour by following two different approaches and
% combining them

%Normalize the image between 1 and 0
imgNor=imgData/max(imgData(:));
[numRows, numSlices, numCols]=size(imgNor);
se1 = strel('sphere',sph_size);

% Binarize the image 
[bw_mask]=binarize_img(imgNor);

% Close the noisy regions, remove small objects and get the contour
whole_mask=imclose(bw_mask,se1);
whole_mask=bwareaopen(whole_mask,pix_removal);
contour=bwperim(whole_mask);

%% Method 1

% Compute a first contour cont_clean_a by counting the first positive element found from
% left to right, from up to down and from down upwards.
step=1;
cont_clean_a=zeros(size(imgNor));fprintf .
for S=1:numSlices
    for R=1:numRows
        for C=1:numCols
            if(contour(R,S,C)==1)
                cont_clean_a(R,S,C)=1;
                if le(step+C,numCols)
                    while(and(le(step+C,numCols),(contour(R,S,C+step)==1)))
                        cont_clean_a(R,S,C+step)=1;
                        step=step+1;
                    end
                end
                step=1;
                break
            end
        end
    end
    for C=1:numCols
        for R=1:numRows
            if(contour(R,S,C)==1)
                cont_clean_a(R,S,C)=1;
                break
            end
        end
    end
    for C=1:numCols
        for R=numRows:-1:1
            if(contour(R,S,C)==1)
                cont_clean_a(R,S,C)=1;
                break
            end
        end
    end
end
fprintf .

%% Method 2

% Compute a second contour cont_clean_b using the gradients of the
% binarized image and removing smaller lines than pix_removal

%[~ ,fy,fz]=gradient(double(whole_mask));
%cont=gt(abs(fy)+2*fz,0);
%cont_clean_b=bwareaopen(cont,pix_removal);
cont_clean_b=zeros(size(contour));

%%

% Combine the two contours
cont_clean=or(cont_clean_a,cont_clean_b);

end

function [whole_mask]=binarize_img(imgNor)
[~,numSlices,~]=size(imgNor);

% Otsu Method
%thresh=graythresh(imgNor);
%whole_mask = imgNor > thresh;

% adaptive thresholding
whole_mask=zeros(size(imgNor));
for i=1:numSlices
    bwslice=imbinarize(squeeze(imgNor(:,i,:)),'adaptive');
    whole_mask(:,i,:)=bwslice; 
end

end