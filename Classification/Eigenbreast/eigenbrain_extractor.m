function [eignbr,pca,latent]=eigenbrain_extractor(y,pname,labels)

okopts={'pca','ica','pls'};fprintf .
cl = find(strncmpi(pname, okopts,numel(pname)));fprintf .

switch cl
    case 1
        y_cent=bsxfun(@minus,double(y(:,:)),mean(y(:,:)));fprintf .
%         try
%         for j=1:P
%             y(j,:,:,:)=y(j,:,:,:)-media; 
%         end
%         catch
%            media=uint8(media);
%            for j=1:P
%             y(j,:,:,:)=y(j,:,:,:)-media; 
%            end
%         end
% %        y=y-repmat(mean(y),[P 1 1 1]);
        fprintf('..Calculating PCA..')
       try
           [pca,eignbr,latent]=princomp(y_cent);
%        
       catch

           [eignbr,pca,latent]=princomp(y_cent,'econ');
       end
           fprintf('pca extraction concluded \n')
        eignbr=eignbr'; 
        [s1 s2 s3 s4]= size(y);
        if numel(size(y))==4
        eignbr=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
        end
    case 2
       
        y_cent=bsxfun(@minus,double(y(:,:)),mean(y(:,:))); fprintf .
        [eignbr,A,latent]=fastica(y_cent);%,'verbose','off');%
        eignbr=eignbr';
        pca=A;
        disp('ica extraction concluded')
        eignbr=eignbr'; 
        [s1 s2 s3 s4]= size(y);
        if numel(size(y))==4
        eignbr=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
        end
    case 3              
        y_cent=bsxfun(@minus,double(y(:,:)),mean(y(:,:)));fprintf .
        if isrow(labels), labels=labels'; end
        [~,~,pca,~,~,~,~,stats] = plsregress(y_cent,squeeze(labels)>0,numel(labels)-1);
        fprintf('pls extraction concluded \n')
        eignbr=stats.W'; 
        [s1 s2 s3 s4]= size(y);
        eignbr=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
    otherwise
        error('No has seleccionado un m�todo correcto');
end
end
