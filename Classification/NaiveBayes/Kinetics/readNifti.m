function niftis = readNifti(folder,normalized,smoothed)
    %%% READNIFTI Reads a nifti image sequence, assuming it has names 1.nii, 2.nii ... 5.nii
    smoothSize = 3;% Must be odd
    for i=1:5
        fileName = strcat(folder,'/',num2str(i),'.nii');
        nii = load_nii(fileName);
        dnii = double(nii.img);
        if smoothed
            dnii = smooth3(dnii,'gaussian',smoothSize);
        end
        niftis(i,:,:,:) = dnii;
    end
    if normalized
        maxVal = max(max(max(max(dnii))));
        niftis = niftis./maxVal;
    end

