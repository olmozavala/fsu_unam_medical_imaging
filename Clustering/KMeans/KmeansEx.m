
close all;
clear all;
clc;

k = 4; % Number of clusters

sep = 14;% Separation between clusters
p = 0.5;
iters = 30;
size = 5000;
color = {'.r' '.b' '.y' '.k' '.m'};

X = [];
Y = [];
for i=1:k
        x1 = sep*rand(1,1) + random('norm',0,1,size,1); %Binomial 
        y1 = sep*rand(1,1) + random('norm',0,1,size,1); %Binomial 
        X = [X x1'];
        Y = [Y y1'];
    end
    plot(X,Y,'.r');


    kmeanx = min(X) + (max(X)-min(X))*rand(k,1);
    kmeany = min(Y) + (max(Y)-min(Y))*rand(k,1);
    cluster = 10*ones(length(X),1);
    for iter=1:iters
        for i=1:length(X)
            minl = 100;
            for c=1:k
                clustL = sqrt( (kmeanx(c) - X(i))^2 + (kmeany(c) -  Y(i))^2);
                if( clustL < minl)
                    cluster(i) = c;
                    minl = clustL;
                end
            end
        end
        hold off;    
        for c=1:k
            cindx = find( cluster == c);
            plot(X(cindx ), Y( cindx),color{c});
            hold on        
            kmeanx(c) = mean(X(cindx));
            kmeany(c) = mean(Y(cindx));
        end
        plot(kmeanx,kmeany,'xg','MarkerSize',10,'LineWidth',4);

        pause(.5);
        pause
    end
