% Info about view_nii.m
% The new positions get updated at 'set_image_value' line 2914
% The mouse click to update the position is 'catched' at line 583
% The positions are saved at /home/olmozavala/Dropbox/OzOpenCL/Matlab_ImagePreProcessing_Kinetic/
% in a file called  TEMP.txt
close all;
clear all;
clc;

addpath('../../../ExternalLibs/niftilib');
addpath('../../../Paths/'); % Add the paths folder

testFolder = false;
dbname = 'DCE-MRI';

% The tested folders/files are: 
selectedFolders ={ '8256301_p1_ok', '1018659_p15_ok', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};

% Initial position of the view
xyzpos = [264 257 48;
            265 257 85;
            266 257 36;
            267 257 41;
            268 257 65;];


folders = setMyPathBreast(testFolder,'DCE-MRI'); % Retrieving folders from production DB

% Iterate over foldersg
for f = 1:length(folders)
    Allfolder = folders{f};
    folderArr = strsplit(Allfolder,'/');
    folder = folderArr{length(folderArr)-1};
    for sf = 1:length(selectedFolders)
        if (isequal(folder,selectedFolders{sf}))
            display(folder);
            fileName = '2.nii';

            % Loading the image
            nii = load_nii(strcat(Allfolder,fileName));

            imgData= nii.img;

            % To visuazlie the data
            % FROM IMAGE WE CHANGE X-y and Y-x because images are flipped
            x = xyzpos(sf,1);
            y = xyzpos(sf,2);
            z = xyzpos(sf,3);
            opt.setviewpoint = [x y z];
            view_nii(nii, opt);
            w = 0;
            while w ==0
                w = waitforbuttonpress;
            end
        end
    end
end
