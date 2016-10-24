
function [ h ] = generateGausian3D( size, gradientSigma )
     size = [size size size];
     siz   = (size-1)/2;
     
     [x,y,z] = meshgrid(-siz(3):siz(3),-siz(2):siz(2),-siz(1):siz(1));
     arg   = -(x.*x + y.*y + z.*z)/(2*gradientSigma*gradientSigma);

     h     = exp(arg);
     h(h<eps*max(h(:))) = 0;

     sumh = sum(h(:));
     if sumh ~= 0,
       h  = h/sumh;
     end;
     
end

