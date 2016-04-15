#workspace()
Pkg.add("Distributions")
Pkg.add("PyPlot")
using Distributions
using PyPlot
k = 4; # Number of clusters

sep = 14;# Separation between clusters
p = 0.5;
iters = 30;
totPoints = 5;
color = [".r" ".b" ".y" ".k" ".m"];

X = [];
Y = [];

for i=1:k
    x1 = sep*rand(1)[1] + rand(Binomial(sep),totPoints); #Binomial 
    y1 = sep*rand(1)[1] + rand(Binomial(sep),totPoints); #Binomial 
    if i == 1
        X = x1';
        Y = y1';
    else
        X = cat(1,X,x1');
        Y = cat(1,Y,y1');
    end
end

plot(X,Y,".r");

# Works until here
kmeanx = minimum(X) + (maximum(X)-minimum(X))*rand(k,1);
kmeany = minimum(Y) + (maximum(Y)-minimum(Y))*rand(k,1);
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
