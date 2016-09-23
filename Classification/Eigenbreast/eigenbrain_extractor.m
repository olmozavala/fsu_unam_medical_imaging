function [eignbr,pca,latent]=eigenbrain_extractor(y,pname,labels)

okopts={'pca','ica','pls'};fprintf .
cl = find(strncmpi(pname, okopts,numel(pname)));fprintf .

switch cl
    case 1
        y_cent=bsxfun(@minus,double(y(:,:)),mean(y(:,:)));fprintf .
        fprintf('..Calculating PCA..')
       try
           [pca,eignbr,latent]=PCA(y_cent);
           %princomp is depricated
           %[pca,eignbr,latent]=princomp(y_cent);
       catch

           [eignbr,pca,latent]=PCA(y_cent);
           %princomp is depricated
           %[eignbr,pca,latent]=princomp(y_cent,'econ');
       end
           fprintf('pca extraction concluded \n')
        eignbr=eignbr'; 
        [~, s2, s3, s4]= size(y);
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
        [~, s2, s3, s4]= size(y);
        if numel(size(y))==4
        eignbr=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
        end
    case 3              
        y_cent=bsxfun(@minus,double(y(:,:)),mean(y(:,:)));fprintf .
        if isrow(labels), labels=labels'; end
        [~,~,pca,~,~,~,~,stats] = plsregress(y_cent,squeeze(labels)>0,numel(labels)-1);
        fprintf('pls extraction concluded \n')
        eignbr=stats.W'; 
        [~, s2, s3, s4]= size(y);
        eignbr=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
    otherwise
        error('No has seleccionado un modo correcto');
end
end
