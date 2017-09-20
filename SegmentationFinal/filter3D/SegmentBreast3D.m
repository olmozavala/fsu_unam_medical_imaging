function [segmented_mask] = SegmentBreast3D( imgData ,mask)


%% Adjustable Parameters


k = 10;% 7 ; % The value of k determines the size of the filter in voxels
        % which will be [2k+1 2k+1 2k+1]

     
medfreq = 1.2;% 1.4;    
%        % medfreq=1/2  ----> One hill
%        % medfreq=1 ---> One hill one valley
%        % medfreq=2 ---> Two hills one valley
%        % medfreq=3   ----> two hills two valleys
% % Alternatively, ask for the tipical width (in pixels) of the wall to detect% 



border=3; % Select: 1 for segmenting following the valleys
          %         3 for segmenting following the hills


per_limit=0.2;  % Size of the lines to preserve in the Edge Map. Proportion (0 to 1). Lines that account a
                % smaller value than per_limit are discarded
                
dil_size=7;  % Size of the sphere used for dilation and erosion (5 for border=1, 7 for border=3 are good numbers)


angleInc=3; % Fixed angle increment between filter orientations in
            % degrees. This should divide evenly into 180

%%

% Generate filters corresponding to these distinct frequencies and
% orientations in 'angleInc' increments.


filter = filtercreation(medfreq,k,angleInc);

%Get the Edge map

[ EM ] = EdgeMap3D(imgData,mask,k,medfreq,filter,angleInc);

 difference=1;
 while difference>0.01
     d=difference;
 [ EMb ] = EdgeMap3D(EM,mask,k,medfreq,filter,angleInc);
 difference=abs(sum(gt(EMb(:),0)-gt(EM(:),0))/sum(EMb(:)))
 if difference>d, break, end 
 EM=EMb;
 end

 EM_coarse=EMb;
%% 
% Repeat with coarser values


%k_factor = 1.4;       % Amplification factor for k
%freq_factor = 0.86;   % Amplification factor for medfreq

%[ EM_coarse_t ] = EdgeMap3D(EM,mask,round(k_factor*k),freq_factor*medfreq,filter,angleInc);

%[ EM_coarse ] = EdgeMap3D(EM_coarse_t,mask,round(k_factor*k_factor*k),freq_factor*medfreq,filter,angleInc);

%%


% Quantize the edge image into 3 different intensity levels (hills,
% valleys and background)
thresh = multithresh(EM_coarse,2);
Quantized_EM = imquantize(EM_coarse,thresh);
Quantized_EM = imfill(Quantized_EM);

[chest_contour]=GetChestContour(imgData,7,5000);

% Select the borders and discard small ones
cc=bwconncomp(Quantized_EM==border);
for j=1:cc.NumObjects
    reg_size(j)=numel(cc.PixelIdxList{j}); 
end
list=find(gt(reg_size/sum(reg_size),per_limit));
im_border=zeros(size(Quantized_EM));
for j=1:numel(list)
    im_border(cc.PixelIdxList{list(j)})=1; 
end

% Join the obtained borders with the chest contour
im_border_joint=or(im_border,chest_contour);

% Dilate the borders to close regions and fill them. Then erode to original
% width
se1 = strel('sphere',dil_size);
im_border_dilated=imdilate(im_border_joint,se1);
im_border_filled=imfill(im_border_dilated,'holes');
segmented_mask=imerode(im_border_filled,se1);

%%%%%%%%%%%%%%%%%%%
% OLD TRY (This never really worked)
%%%%%%%%%%%%%%%%%%%



% Iterate the process of extracting the edge map until there is no
% improvement
%
% difference=1;
% while difference>0.001
%     d=difference;
% [ EMb ] = EdgeMap3D(EM,mask,k,medfreq);
% difference=abs(sum(gt(EMb(:),0)-gt(EM(:),0))/sum(EMb(:)))
% if difference>d, return, end 
% EM=EMb;
% end
%%%%%%%%%




% Erode it to separate the inner organs from the chest
% SE=strel('disk',1,0);
% [propdiff,obsiz_list,EM_eroded]=erode_intwo(EM,SE);
% 
% if propdiff(1)<0.5
%     n=1;
%     while propdiff(1)<0.5
%     SE=strel('square',1+n);
%     [propdiff,obsiz_list,EM_eroded]=erode_intwo(EM,SE);
%     n=n+1;
%     end
% end
% % if there is a object that contributes to the cumulative sum more than the
% % 1% in the third place means that the two first objects are big, so
% % removing one of them might be taking an important part away
% if propdiff(2)>1
%     EM_cropped=bwareaopen(EM_eroded,obsiz_list(3)+1);
% else
%     EM_cropped=bwareaopen(EM_eroded,obsiz_list(2)+1);
% end
% 
% %fill the holes of the obtained image by morphological closing it first
% %and then filling the holes
% SE2=strel('disk',10,0);
% 
% 
% for i=1:size(EM_cropped,2)
% closed=imclose(squeeze(EM_cropped(:,i,:)), SE2);
% filled=imfill(closed,'holes');
% filaclos(:,i,:)=filled;
% end
end

