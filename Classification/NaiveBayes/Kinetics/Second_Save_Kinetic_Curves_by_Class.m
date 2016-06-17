% Reads the positions of each file and obtains the kinetic curves of all of them,
% separating the data in the four classes 'background', 'softtissue', 'chest', 'lesion'
function dispAverageKinetics()
close all;
clear all;
clc;

% Info about view_nii.m
% The new positions get updated at 'set_image_value' line 2914
% The mouse click to update the position is 'catched' at line 583

addpath('../../../ExternalLibs/niftilib');
addpath('../../../Paths/'); % Add the paths folder
filesFolder = './Data_Positions/';

folders ={ '0847664_p6_ok', '1018659_p15_ok', '5641445_p1_ok_non-mass_from_mass', '6107252_p2_ok', '8256301_p1_ok' };
saveFolder = './Kinetic_Curves_by_classes/';

testFolder = false;
dbname = 'DCE-MRI';

mypath = getMyPath(testFolder,'DCE-MRI'); % Retrieving folders from production DB

totFiles = length(folders);

padding = 900;
width = 800;
height = 400;

examplesL = 25;
examplesNL = 95;
tot_seq = 5; % Number of temporal sequences

% 5 files x 30 
lesion = zeros(totFiles*examplesL,tot_seq);
nolesion = zeros(totFiles*examplesNL,tot_seq);

for i=1:totFiles
    % Read file
    fname_lesion = strcat(filesFolder,'Lesion/',folders{i},'.txt');
    fname_no_lesion = strcat(filesFolder,'noLesion/',folders{i},'.txt');

    display(strcat('Reading positions file: ',fname_lesion));
    file_id_lesion = fopen(fname_lesion);
    file_id_no_lesion = fopen(fname_no_lesion);

    % Read nifti normalized
    display(strcat('Reading nifti files from: ',strcat(mypath,folders{i})))
    normalized = true;
    smoothed = true;
    niftis = readNifti(strcat(mypath,folders{i}),normalized,smoothed);

    % --------------- Read lesions -------------- 
    display('Reading lesions positions...');
    pos = readPositions(file_id_lesion,0,examplesL);
    % Display kinetic curves
    %figure('Position',[100 100 width height])
    lesion(examplesL*(i-1)+1:examplesL*i,:) = obtainKineticCurves(niftis,pos,examplesL,tot_seq);
    %title('Lesion');

    %-------------------- Read no lesions -------------------- 
    display('Reading NO lesion positions...');
    pos = readPositions(file_id_no_lesion,0,examplesNL);
    % Display kinetic curves
    %figure('Position',[padding 100 width height])
    nolesion(examplesNL*(i-1)+1:examplesNL*i,:) = obtainKineticCurves(niftis,pos,examplesNL,tot_seq);
    %title('No Lesion');

    pause(.5)
    fclose(file_id_lesion);
    fclose(file_id_no_lesion);
end

fprintf('Displaying the average curves..\n');
hold on
plot(mean(lesion),'r','LineWidth',3);
plot(mean(nolesion),'k','LineWidth',3);
legend( 'Lesion','nolesion') ;
figure
fprintf('Displaying all the curves..\n');
hold on
plot(lesion','--r','LineWidth',1);
plot(nolesion','--k','LineWidth',1);

%========== Saving the curves ============
fprintf('Displaying all the curves..\n');
save(strcat(saveFolder,'lesions'),'lesion')
save(strcat(saveFolder,'nolesions'),'nolesion')

% Reads the positions and indicates how many lines should it read
function pos = readPositions(file_id_lesion,jump,readTot)
    % Initialize position vector
    pos = zeros(readTot,3);
    for i = 1:readTot
        pos(i,:) = fscanf(file_id_lesion,'%d %d %d\n',3);
    end

% This function is usede to read the kinetic curves of the desired position,
% it makes a gaussian of the 2x2 neighbors and computes the average of that curve
function curve = obtainKineticCurves(niftis, pos, tot,tot_seq)

    curve = zeros(tot,5);
    nnsize = 2;
    visualize = false;

    % Iterate over the images
    for i=1:tot_seq
        % Loading the image
        imgData = squeeze(niftis(i,:,:,:));
        % Iterate over the positions
        for p = 1:tot
            x = pos(p,1);
            y = pos(p,2);
            z = pos(p,3);
            if(visualize)
                vissize = 2*nnsize;
                sample = imgData(x-vissize:x+vissize,y-vissize:y+vissize,:);
                imshow(sample(:,end:-1:1,z)',[0 1500]);
            end
            % Smoothing with a gaussian
            boxVal = imgData(x-nnsize:x+nnsize,y-nnsize:y+nnsize,z-nnsize:z+nnsize);
            curve(p,i) = mean(mean(mean(boxVal)));
        end
    end
