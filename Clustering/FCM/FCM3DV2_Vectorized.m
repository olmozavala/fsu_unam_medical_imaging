close all;
clear all;
clc;

k = 4; % Number of clusters

sep = 14;% Separation between clusters
p = 0.5;
iters = 20;
totPointsPerCluster = 5000;
color = {'.r' '.b' '.y' '.k' '.m'};

X = [];
Y = [];
Z = [];

f = figure('Position',[300 200 500 400]); % For position at left screen

display('Initializing random points....');
%Generates 5000 points for each random center using binomial distribution
for i=1:k
    x1 = sep*rand(1,1) + random('norm',0,1,totPointsPerCluster,1); %Binomial 
    y1 = sep*rand(1,1) + random('norm',0,1,totPointsPerCluster,1); %Binomial 
    z1 = sep*rand(1,1) + random('norm',0,1,totPointsPerCluster,1); %Binomial 
    X = [X x1'];
    Y = [Y y1'];
    Z = [Z z1'];
end
scatter3(X,Y,Z,'.r');

totPoints = totPointsPerCluster*k;

%Obtains initial positions of clusters
display('Initializing clusters with random positions');

% kmeanx and kmeany contains the center position of the clusters
kmeanx = min(X) + (max(X)-min(X))*rand(k,1);
kmeany = min(Y) + (max(Y)-min(Y))*rand(k,1);
kmeanz = min(Z) + (max(Z)-min(Z))*rand(k,1);

hold on;
scatter(kmeanx,kmeany,kmeanz,'xg','LineWidth',4);

display('Running FCM....');

cluster = ones(totPoints,1);
% U contains the probability for each point to belong to each of the clusters the size of U should
% always be (N,k) where N is the total number of points and k the number of clusters
U = ones(totPoints,k);

for iter=1:iters
    minDist = 10000*ones(1,totPoints); %Initialize with a large ditance
    for c=1:k
        % Find the closest distances for each cluster
        clusterDist = ( (kmeanx(c) - X).^2 + (kmeany(c) -  Y).^2  + (kmeanz(c) - Z).^2);
        %If the distance is less than current minimum, then we assig this cluster to thepoint
        idx = find(clusterDist < minDist);
        cluster(idx) = c;
        minDist(idx) = clusterDist(idx);

        % For each cluster we compute the membership matrix 
        U(:,c) = 0;            
        for v=1:k %Iterates over clusters
            U(:,c) = U(:,c) + ( ( (kmeanx(c) - X).^2  + (kmeany(c) - Y).^2  + (kmeanz(c) - Z).^2 ) ./ ...
            ( (kmeanx(v) - X).^2  + (kmeany(v) - Y).^2 + (kmeanz(v) - Z).^2 ) )';
        end
        U(:,c) = 1./U(:,c);            
    end

    hold off;    

    for c=1:k
        cindx = find( cluster == c);
        scatter3(X(cindx ), Y( cindx), Z(cindx),color{c});
        hold on        
    end
    % Displays old centers
    scatter(kmeanx,kmeany,kmeanz,'xg','LineWidth',4);
    %saveas(f,num2str(iter),'png');

    % Computes new centers
    for c=1:k
        kmeanx(c) = X*U(:,c)/sum(U(:,c));
        kmeany(c) = Y*U(:,c)/sum(U(:,c));
        kmeanz(c) = Z*U(:,c)/sum(U(:,c));
    end 

    % Displays New centers
    %     plot(kmeanx,kmeany,'xc','MarkerSize',10,'LineWidth',4);    
    pause(.1);
    %     pause
end
