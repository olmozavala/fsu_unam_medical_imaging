function [ DiceCoef] = DiceSimilarity2DImage(img1, img2)
%The steps are:
%1. set one image non-zero values as 200
img1(img1>0)=200;

%2. set second image non-zero values as 300
img2(img2>0)=300;

%3. set overlap area 100
OverlapImage = img2-img1;

%4. count the overlap100 pixels
[r,c,v] = find(OverlapImage==100);
countOverlap100=size(r);

%5. count the image200 pixels
[r1,c1,v1] = find(img1==200);
img1_200=size(r1);

%6. count the image300 pixels
[r2,c2,v2] = find(img2==300);
img2_300=size(r2);

%7. calculate Dice Coef
DiceCoef = 2*countOverlap100/(img1_200+img2_300);
end