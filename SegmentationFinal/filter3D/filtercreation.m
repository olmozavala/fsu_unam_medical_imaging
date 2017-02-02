function [filter,sze,reffilter]=filtercreation(unfreq,kx,ky,kz,angleInc)
sze = zeros(length(unfreq),1);
filter = cell(length(unfreq),length(unfreq),180/angleInc);
for k = 1:length(unfreq)
    sigmax = 1/unfreq(k)*kx;
    sigmay = 1/unfreq(k)*ky;
    sigmaz = 1/unfreq(k)*kz;
    sze(k) = round(3*max(sigmax,max(sigmay,sigmaz)));
    [x,y,z] = meshgrid(-sze(k):sze(k));
    reffilter = exp(-(x.^2/sigmax^2 + y.^2/sigmay^2 +  z.^2/sigmaz^2)/2)...
        .*cos(2*pi*unfreq(k)*x);
    
    % Generate rotated versions of the filter.  Note orientation
    % image provides orientation *along* the ridges, hence +90
    % degrees, and imrotate requires angles +ve anticlockwise, hence
    % the minus sign.
    filterb=zeros(size(reffilter));
    count=1;
    for o1 = 1:180/angleInc
        for i=1:size(reffilter,3)
            reffilter2D=squeeze(reffilter(:,:,i));
            filterslice = imrotate(reffilter2D,-(o1*angleInc+90),'bilinear','crop');
            filterb(:,:,i)=filterslice;
        end
        if count>10, fprintf('.'); count=1; end
            
        for o2=1:180/angleInc
            for i=1:size(reffilter,1)
                reffilter2D=squeeze(filterb(i,:,:));
                filterslice = imrotate(reffilter2D,(o2*angleInc),'bilinear','crop');
                filterbr(i,:,:)=filterslice;
            end
            filter{o1,o2,k}=filterbr;
        end
        count=count+1;
    end
end
fprintf('3D filter created\n')
end