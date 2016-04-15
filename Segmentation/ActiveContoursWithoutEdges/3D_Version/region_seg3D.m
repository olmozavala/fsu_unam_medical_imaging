% Region Based Active Contour Segmentation
%
% seg = region_seg(I,init_mask,max_its,alphaVal,displayVal)
%
% Inputs: I           2D image
%         init_mask   Initialization (1 = foreground, 0 = bg)
%         max_its     Number of iterations to run segmentation for
%         alphaVal       (optional) Weight of smoothing term
%                       higer = smoother.  default = 0.2
%         displayVal     (optional) displays intermediate outputs
%                       default = true
%
% Outputs: seg        Final segmentation mask (1=fg, 0=bg)
%
% Description: This code implements the paper: "Active Contours Without
% Edges" By Chan Vese. This is a nice way to segment images whose
% foregrounds and backgrounds are statistically different and homogeneous.
%
% Example:
% img = imread('tire.tif');
% m = zeros(size(img));
% m(33:33+117,44:44+128) = 1;
% seg = region_seg(img,m,500);
%
% Coded by: Olmo Zavala (olmozavala.com) 2d version from Shawn Lankton (www.shawnlankton.com)
%------------------------------------------------------------------------

function [seg timeSDF]= region_seg3D(I,init_mask,max_its,alphaVal,displayVal)    

    %-- default value for parameter alphaVal is .1
    if(~exist('alphaVal','var')) 
        alphaVal = .2; 
    end
    %-- default behavior is to displayVal intermediate outputs
    if(~exist('displayVal','var'))
        displayVal = true;
    end

    %-- Create a signed distance map (SDF) from mask
    tic();
    phi = mask2phi(init_mask);
    phi = double(phi);
    timeSDF = toc();

    if(displayVal)
        figure('Position',[100,100,1000,600]); hold on;
        subplot(1,2,1); 
        view3DOZ(double(I),-1,1);    
        subplot(1,2,2); 
        view3DOZ(phi,0,0);
    end

    totTime = 0;
    indx = 1;
    %--main loop
    for its = 0:1:max_its   % Note: no automatic convergence test
        %waitforbuttonpress;
        idx = find(phi <= 2.2 & phi >= -2.2);  %get the curve's narrow band
        %idx = find(phi <= 100 & phi >= -100);  %get the curve's all

        %phiPrev = reshape(phi,[20,20,20]);

        %-- find interior and exterior mean
        upts = find(phi<=0);                 % interior points
        vpts = find(phi>0);                  % exterior points
        u = sum(I(upts))/(length(upts)+eps); % interior mean
        v = sum(I(vpts))/(length(vpts)+eps); % exterior mean

        curvature = get_curvature3D(phi,idx);  % force from curvature penalty
        %curv2D = reshape(curvature,[20,20,20]);
        %avgIn = u
        %avgOut = v

        F = (I(idx)-u).^2-(I(idx)-v).^2;         % force from image information
        %F2D = reshape(F,[20,20,20]);

        %maxF = max(abs(F))

        dphidt = F./max(abs(F)) + alphaVal*curvature;  % gradient descent to minimize energy             
        %dphidt2D = reshape(dphidt,[20,20,20]);

        %-- maintain the CFL condition
        dt = .45/(max(dphidt)+eps);
        %maxDphiDt = max(dphidt)

        %-- evolve the curve
        phi(idx) = phi(idx) + dt.*dphidt;
        %phi2D= reshape(phi,[20,20,20]);

        %-- Keep SDF smooth            
        phi = sussman(phi, .5);
        %phiSm= reshape(phi,[20,20,20]);            


        %if(mod(its,10) == 0)
        if(displayVal)
            subplot(1,2,2); view3DOZ(double(phi),-1,1);    
            subplot(1,2,2); view3DOZ(phi,0,0);            
            pause(.1);
        end
    end
    if(displayVal)
        subplot(1,2,2); view3DOZ(double(phi),-1,1);    
        subplot(1,2,2); view3DOZ(phi,0,0);            
    end

    %-- make mask from SDF
    seg = phi<=0; %-- Get mask from levelset

    %---------------------------------------------------------------------
    %---------------------------------------------------------------------
    %-- AUXILIARY FUNCTIONS ----------------------------------------------
    %---------------------------------------------------------------------
    %---------------------------------------------------------------------

    %-- Displays the image with curve superimposed
function showCurveAndPhi(I, phi, i)
    imshow(I,'initialmagnification',200,'displayrange',[0 255]); hold on;
    contour(phi, [0 0], 'g','LineWidth',4);
    contour(phi, [0 0], 'k','LineWidth',2);
    hold off; title([num2str(i) ' Iterations']); drawnow;

    %-- converts a mask to a SDF
function phi = mask2phi(init_a)
    phi=bwdist(init_a)-bwdist(1-init_a)+im2double(init_a)-.5;


    %-- compute curvature along SDF
function curvature = get_curvature3D(phi,idx)
    [dimy, dimx, dimz] = size(phi);        
    [y x z] = ind2sub([dimy,dimx,dimz],idx);  % get subscripts

    %-- get subscripts of neighbors
    ym1 = y-1; xm1 = x-1; zm1 = z-1;
    yp1 = y+1; xp1 = x+1; zp1 = z+1;

    %-- bounds checking  
    ym1(ym1<1) = 1; xm1(xm1<1) = 1; zm1(zm1<1) = 1;
    yp1(yp1>dimy)=dimy; xp1(xp1>dimx) = dimx;   zp1(zp1>dimz) = dimz; 

    %-- get indexes for 26 neighbors
    % First 6 'straight'
    dn = sub2ind(size(phi),yp1,x,z); % down
    up = sub2ind(size(phi),ym1,x,z); % up
    lf = sub2ind(size(phi),y,xm1,z); % left
    ri = sub2ind(size(phi),y,xp1,z); % right
    ccurr = sub2ind(size(phi),y,x,zm1); % close
    fcurr = sub2ind(size(phi),y,x,zp1); % far

    % 4 from corners of 'same' z
    ul = sub2ind(size(phi),ym1,xm1,z); % upper left
    ur = sub2ind(size(phi),ym1,xp1,z); % upper right 
    dl = sub2ind(size(phi),yp1,xm1,z); % lower left
    dr = sub2ind(size(phi),yp1,xp1,z); % lower right

    % 4 from corners of 'far' z
    ful = sub2ind(size(phi),ym1,xm1,zp1); % upper left
    fur = sub2ind(size(phi),ym1,xp1,zp1); % upper right
    fdl = sub2ind(size(phi),yp1,xm1,zp1); % lower left
    fdr = sub2ind(size(phi),yp1,xp1,zp1); % lower right

    % 4 from non-corners of 'far' z
    fup = sub2ind(size(phi),ym1,x,zp1); %up
    fdn = sub2ind(size(phi),yp1,x,zp1); %down
    flf = sub2ind(size(phi),y,xm1,zp1); %left
    fri = sub2ind(size(phi),y,xp1,zp1); %right

    % 4 from corners of 'close' z
    cul = sub2ind(size(phi),ym1,xm1,zm1); % upper left
    cur = sub2ind(size(phi),ym1,xp1,zm1); % upper right
    cdl = sub2ind(size(phi),yp1,xm1,zm1); % lower left
    cdr = sub2ind(size(phi),yp1,xp1,zm1); % lower right

    % 5 from non-corners of 'close' z
    cup = sub2ind(size(phi),ym1,x,zm1); %up
    cdn = sub2ind(size(phi),yp1,x,zm1); %down
    clf = sub2ind(size(phi),y,xm1,zm1); %left
    cri = sub2ind(size(phi),y,xp1,zm1); %right

    %-- get central derivatives of SDF at x,y
    phi_x  = phi(ri) - phi(lf);
    phi_y  = phi(up) - phi(dn);
    phi_z  = phi(fcurr) - phi(ccurr);
    phi_xx = phi(lf)-2*phi(idx)+phi(ri);
    phi_yy = phi(dn)-2*phi(idx)+phi(up);
    phi_zz = phi(ccurr)-2*phi(idx)+phi(fcurr);
    phi_xy = 0.25*phi(dr) - 0.25*phi(ul) + ...
        0.25*phi(ur) - 0.25*phi(dl);
    phi_xz = 0.25*phi(fri) - 0.25*phi(clf) + ...
        0.25*phi(flf) - 0.25*phi(cri); 
    phi_zy = 0.25*phi(fup) - 0.25*phi(cdn) + ...
        0.25*phi(fdn) - 0.25*phi(cup);
    phi_x2 = phi_x.^2;
    phi_y2 = phi_y.^2;
    phi_z2 = phi_z.^2;

    %-- compute curvature (Kappa)
    curvature = (( phi_x2.*phi_yy + phi_x2.*phi_zz + phi_y2.*phi_xx + ...
        phi_y2.*phi_zz + phi_z2.*phi_xx + phi_z2.*phi_yy  ...
        - 2.*phi_x.*phi_y.*phi_xy  -2.*phi_x.*phi_z.*phi_xz - 2.*phi_y.*phi_z.*phi_zy) ./  ...
        (phi_x2 + phi_y2 + phi_z2 + eps).^(3/2)); 

    %-- Converts image to one channel (grayscale) double
function img = im2graydouble(img)    
    [dimy, dimx, c] = size(img);
    if(isfloat(img)) % image is a double
        if(c==3) 
            img = rgb2gray(uint8(img)); 
        end
    else           % image is a int
        if(c==3) 
            img = rgb2gray(img); 
        end
        img = double(img);
    end

    %-- level set re-initialization by the sussman method
function D = sussman(D, beta)
    % forward/backward differences
    ozR = shiftR(D);
    ozL = shiftL(D);
    ozD = shiftD(D);
    ozU = shiftU(D);
    ozF = shiftFar(D);
    ozN = shiftNear(D);
    a = D - shiftR(D);
    b = shiftL(D) - D; % forward
    c = D - shiftD(D); % backward
    d = shiftU(D) - D; % forward
    e = D - shiftFar(D); % backward
    f = shiftNear(D) - D; % forward

    a_p = a;  a_n = a; % a+ and a-
    b_p = b;  b_n = b;
    c_p = c;  c_n = c;
    d_p = d;  d_n = d;
    e_p = e;  e_n = e;
    f_p = f;  f_n = f;

    a_p(a < 0) = 0;
    b_p(b < 0) = 0;
    c_p(c < 0) = 0;
    d_p(d < 0) = 0;
    e_p(e < 0) = 0;
    f_p(f < 0) = 0;

    a_n(a > 0) = 0;
    b_n(b > 0) = 0;
    c_n(c > 0) = 0;
    d_n(d > 0) = 0;
    e_n(e > 0) = 0;
    f_n(f > 0) = 0;

    dD = zeros(size(D));
    D_neg_ind = find(D < 0);
    D_pos_ind = find(D > 0);
    dD(D_pos_ind) = sqrt(max(a_p(D_pos_ind).^2, b_n(D_pos_ind).^2) ...
        + max(c_p(D_pos_ind).^2, d_n(D_pos_ind).^2) ...
        + max(e_p(D_pos_ind).^2, f_n(D_pos_ind).^2)) - 1;
    dD(D_neg_ind) = sqrt(max(a_n(D_neg_ind).^2, b_p(D_neg_ind).^2) ...
        + max(c_n(D_neg_ind).^2, d_p(D_neg_ind).^2) ...
        + max(e_n(D_neg_ind).^2, f_p(D_neg_ind).^2)) - 1;

    %D = D - beta .* sussman_sign(D) .* dD;
    D = D - beta .* (D ./ sqrt(D.^2 + 1)) .* dD;

    %-- whole matrix derivatives
function shift = shiftD(M)
    shift = [M(1,:,:); M(1:end-1,:,:)];

function shift = shiftL(M)
    shift = cat(2, M(:,2:end,:),M(:,end,:));

function shift = shiftR(M)
    shift = cat(2, M(:,1,:),M(:,1:end-1,:));

function shift = shiftU(M)
    shift = [M(2:end,:,:); M(end,:,:)];

function shift = shiftFar(M)
    shift = cat(3,[M(:,:,1)],[M(:,:,1:end-1)]);

function shift = shiftNear(M)
    shift = cat(3,[M(:,:,2:end)],[M(:,:,end)]);

function S = sussman_sign(D)
    S = D ./ sqrt(D.^2 + 1);    
