% clc;
% close all;
% clear all;
% 
% 
% I = load_nii('Gradient.nii'); %-- load the image
% imgData = I.img;

function view3DOZ( imgData, isovalue, asSlices)

if(asSlices)
    dims = size(imgData);
    xslice = floor(dims(1)/2);
    yslice = floor(dims(2)/2);
    zslice = floor(dims(3)/2);
    slice(imgData,xslice,yslice,zslice);
    view(3);
    axis on;
    grid on;
else
    dims = size(imgData);
    [x,y,z] = meshgrid(1:dims(1), 1:dims(2), 1:dims(3));

    color = [0 1 1];
    p = patch(isosurface(x,y,z,imgData,isovalue));
    isonormals(imgData,p);
    set(p,'FaceColor',color,'EdgeColor','none');

    view([-10 40]);
    axis on;
    grid on;
    light;
    lighting phong;
    camlight('left');
end
end
