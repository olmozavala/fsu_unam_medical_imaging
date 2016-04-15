%% This function creates a Gaussian mask of nxn
function gauss2d = oz_gaussMask(n,sigma)

f = @(x,y,sigma) ( 1/(2*pi*sigma^2) ) .* exp( -(x.^2+y.^2)/(2*sigma^2) );

width = 5;
height = 5;
x = [-width/2:width/n:width/2];
y = [-height/2:height/n:height/2];

[X,Y] = meshgrid(x,y);

gauss2d= f(X,Y,sigma);

%Normalization of the gauss function
total = sum(sum(gauss2d));
gauss2d = gauss2d./total;%It doens't validate that the minimum can be 0

%surf(gauss2d);
