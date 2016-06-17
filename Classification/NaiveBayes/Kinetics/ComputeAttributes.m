% This function reads the curves for each class, obtain a list of features from them, creates a classifier 
function curveMatrix = ComputeAttributes(kVals)
    totAttributes = 14;
    currSize = length(kVals);
    curveMatrix = zeros(currSize,totAttributes);
    curveMatrix(1:currSize,1:5) = kVals;

    %------------------ Compute slopes -------------
    curveMatrix(:,6) = curveMatrix(:,2) - curveMatrix(:,1);
    curveMatrix(:,7) = curveMatrix(:,3) - curveMatrix(:,2);
    curveMatrix(:,8) = curveMatrix(:,4) - curveMatrix(:,3);
    curveMatrix(:,9) = curveMatrix(:,5) - curveMatrix(:,4);

    %------------------ Compute mean -------------
    curveMatrix(:,10) = mean( curveMatrix(:,1:5),2 );

    %------------------ Compute time to peak -------------
    [del curveMatrix(:,11)] = max( curveMatrix(:,1:5)');

    %------------------ Compute time of max slope -------------
    [del curveMatrix(:,12)] = max( curveMatrix(:,6:9)');

    %------------------ No 'sharp' decrease -------------
    curveMatrix(:,13) = min( (curveMatrix(:,6:9) > -1)')';

    %------------------ Max intensity value  -------------
    curveMatrix(:,14) = max(curveMatrix(:,1:5)');
