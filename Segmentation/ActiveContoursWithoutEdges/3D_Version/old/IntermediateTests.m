close all;
clear all;
clc;

addpath('./3drend/');

%% Testing how to comput 3D SDF from mask (working)

mask = zeros(10,10,10);
mask(4:6,4:6,4:6) = 1;

%-- converts a mask to a SDF
phi=bwdist(mask)-bwdist(1-mask)+im2double(mask)-.5;

%H = vol3d('CData',phi,'texture','2D')
H = vol3d('CData',phi)
