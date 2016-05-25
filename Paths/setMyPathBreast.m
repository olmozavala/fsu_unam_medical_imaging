function imageFolders = setMyPathBreast(testMode,dbname)
% SETMYPATHSBREAST Sets the path of the breast DB folder and returns the list of folders 
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

        folderPath = '/media/BKNotToImportant/BigData_Images_and_Others/MedicalImaging/Breast/';% Olmo's Path
    end

    workingFolder = strcat(folderPath, dbname,'/');
    addpath( workingFolder );
    tempFolders = dir(workingFolder);
    
    count = 1;
    for i=3:length(tempFolders)
        if(tempFolders(i).isdir)
            imageFolders(count) = {strcat(workingFolder,tempFolders(i).name,'/')};
            count = count + 1;
        end
    end
end
