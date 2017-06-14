function [ EM] = SegmentBreast3D( imgData ,mask)

% k=0.5; % The value of k determines hoy many hills and valeys the filter is going to have:
% width=round(size(imgData,1)/15);


% medfreq=1/width;
k = 3.49 ; % The value of k determines the size of the filter in voxels
        % which will be [6k+1 6k+1 6k+1]

     
medfreq = 1.2;    
%        % medfreq=1/2  ----> One hill
%        % medfreq=1 ---> One hill one valley
%        % medfreq=2 ---> Two hills one valley
%        % medfreq=3   ----> two hills two valleys
% % Alternatively, ask for the tipical width (in pixels) of the wall to detect


%Get the Edge map

[ EM1 ] = EdgeMap3D(imgData,mask,k,medfreq);
[ EM2 ] = EdgeMap3D(EM1,mask,k,medfreq);
[ EM3 ] = EdgeMap3D(EM2,mask,k,medfreq);
[ EM4 ] = EdgeMap3D(EM3,mask,k,medfreq);
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

