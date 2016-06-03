function dbpath = getMyPath(testMode,dbname)
% GETMYPATH Gets the path of the breast DB folder 
%   This file should not be updated into the Repository. 
%   Each person should modify this file and add their own paths.
%   boolean testMode Indicates if we are testing in the small DB or in the large DB
%   str     dbname   Indicates which of the DBs are we using, currently it can be ['DCE-MRI', 'DBT']

    if( testMode == true)
        % This path should point to the test folder. Currently the one we were using at Dropbox
        % We can discuss what is the best way to organize the test folder
        folderPath = '/home/olmozavala/Dropbox/MedicalImaging_Group/Test_Data/Breast/';% Olmo's Path
    else
        % This path should point to the root folder of our DataBase: /research/ameyerbaese/DataBases/
        % But in your local machine. 
        folderPath = '/media/USBSimpleDrive/BigData_Images_and_Others/MedicalImaging/Breast/';
    end

    dbpath = strcat(folderPath, dbname,'/');
