function [ filaclos] = SegmentBreast3D( imgData ,mask)

k=0.5; % The value of k determines hoy many hills and valeys the filter is going to have:
       % k=1/4  ----> One hill
       % k=1/2 ---> One hill one valley
       % k=3/4 ---> Two hills one valley
       % k=1   ----> two hills two valleys

%Get the Edge map
[ EM ] = EdgeMap3D(imgData,mask,k);

% Erode it to separate the inner organs from the chest
SE=strel('disk',1,0);
[propdiff,obsiz_list,EM_eroded]=erode_intwo(EM,SE);

if propdiff(1)<0.5
    n=1;
    while propdiff(1)<0.5
    SE=strel('square',1+n);
    [propdiff,obsiz_list,EM_eroded]=erode_intwo(EM,SE);
    n=n+1;
    end
end
% if there is a object that contributes to the cumulative sum more than the
% 1% in the third place means that the two first objects are big, so
% removing one of them might be taking an important part away
if propdiff(2)>1
    EM_cropped=bwareaopen(EM_eroded,obsiz_list(3)+1);
else
    EM_cropped=bwareaopen(EM_eroded,obsiz_list(2)+1);
end

%fill the holes of the obtained image by morphological closing it first
%and then filling the holes
SE2=strel('disk',10,0);


for i=1:size(EM_cropped,2)
closed=imclose(squeeze(EM_cropped(:,i,:)), SE2);
filled=imfill(closed,'holes');
filaclos(:,i,:)=filled;
end

end

