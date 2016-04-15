% This file should not be updated into the Repository. 
% Each person should modify this file and add their own paths.

function imageFolder = setMIpaths(testMode)
    if( testMode == true)
        % This path should point to the test folder. Currently the one we were using at Dropbox
        % We can discuss what is the best way to organize the test folder

        %imageFolder = 'PATH TO ROOT TEST DATABASE' 
        imageFolder = '/home/olmozavala/Dropbox/MedicalImaging_Group/Test_Data';% Olmo Path
    else
        % This path should point to the root folder of our DataBase: /research/ameyerbaese/DataBases/
        % But in your local machine. 

        % imageFolder =  'PATH TO ROOT DATABASE' ;
        imageFolder = '/media/BKNotToImportant/BigData_Images_and_Others/MedicalImaging';% Olmo Path
    end

    addpath( imageFolder );
end
