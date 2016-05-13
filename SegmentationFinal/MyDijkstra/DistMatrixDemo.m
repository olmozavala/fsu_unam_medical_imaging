%Test 
StartNode = 1;
EndNode = 10*15;
M = 10;
N = 15;
conn = 8;%4 or 8 - connected neighborhood for linking pixels

CostMat = rand(M, N)*254+1;                                         
CostMat(4:6, 6:9) = 255;

D = im2graph(CostMat, conn);

%my code
[path2, spcost] = dijkstra_sparse(D, StartNode, EndNode);

%compare to matlabs code
[dist, path, pred] = graphshortestpath(D, StartNode, EndNode);

%display results
[y, x] = ind2sub([M N], path);
figure; imagesc(CostMat); colormap gray; axis image;
hold on; plot(x, y, '-.')
set(gca,'YDir','reverse')

%check to see both version are the same
disp('Both paths are the same?');
sum(path2 == path)/length(path)
