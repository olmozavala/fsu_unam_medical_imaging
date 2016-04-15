function [ Outputlast ] = aproxPosteriorBorder( BodyFatMasksROI )
%UNTITLED37 Summary of this function goes here
%   Detailed explanation goes here

DataSize = size (BodyFatMasksROI) ;
numRows = DataSize(1);
numCols = DataSize(2);
nImages = DataSize(3);

Outputlast = zeros(size(BodyFatMasksROI));

for x = 1:nImages;
    BodyFatMaskROI = BodyFatMasksROI(:,:,x);    
    Output = zeros(numRows,numCols);
    for R=1:numRows
        for C=1:numCols
            if(BodyFatMaskROI(R,C)==1)
                Output(R,C)=1;
                break
            end
        end
    end  
    Outputlast(:,:,x) = Output;

end


end

