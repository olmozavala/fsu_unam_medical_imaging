function lastFolder = getLastFolder(folder)
% SETMYPATHSBREAST Get the last folder from a complete path

    folderArr = strsplit(folder,'/');
    lastFolder = folderArr{end-1};

end
