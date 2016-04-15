%% This is an example of how to compute something inside all the folders of the DB of interest
close all;
clear all;
clc;

addpath('../ExternalLibs/niftilib'); % Adding external libraries (if needed)
addpath('../Paths/'); % Add the paths folder
outputFolder = '../../Outputs'; % Set output folder

testFolder = false; % Indicates if we are using the test folder or not
dbname = 'DCE-MRI'; % Which DB are we using [DCE-MRI, NME, ...]
poolsize = 4; % Size of the parallel pool

folders = setMIpathsBreast(testFolder,'DCE-MRI'); % Retrieving folders from production DB

% Instantiate the parallel process
if(length(gcp('nocreate')) == 0)
    poolobj = parpool(poolsize);
end

% Iterate over folders
parfor f = 1:length(folders)
    folder = folders{f};
    addpath(folder);

    display(strcat('Apply algorithm for folder: ',folders{f}));
end

% To delete the parallel pool call
% delete(gcp);
