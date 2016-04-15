%m1=SegmentBreast('/Users/macbookpro/PhD/Data/Testsubject/1.nii');
%m2=SegmentBreast('/Users/macbookpro/PhD/Data/Testsubject/2.nii');
%m3=SegmentBreast('/Users/macbookpro/PhD/Data/Testsubject/3.nii');
%m4=SegmentBreast('/Users/macbookpro/PhD/Data/Testsubject/4.nii');
%m5=SegmentBreast('/Users/macbookpro/PhD/Data/Testsubject/4.nii');

for x = 1:size(m1,3); 
      imshow(m1(:,:,x),[])
      pause(0.01)
end
 for x = 1:size(m1,3); 
      imshow(m2(:,:,x),[])
      pause(0.01)
 end
 for x = 1:size(m1,3); 
      imshow(m3(:,:,x),[])
      pause(0.01)
 end
 for x = 1:size(m1,3); 
      imshow(m4(:,:,x),[])
      pause(0.01)
 end
 for x = 1:size(m1,3); 
      imshow(m5(:,:,x),[])
      pause(0.01)
 end