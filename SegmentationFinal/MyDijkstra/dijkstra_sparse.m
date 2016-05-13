function [path, path_cost] = dijkstra_sparse(DistanceMatrix, start, target)
% This is an implementation of the dijkstras algorithm, which finds the 
% minimal cost path between two nodes. It's only supposed to solve the 
% problem on positive weighted instances.
%
%INPUTS:
% DistanceMatrix: Weighted Graph represent by a sparse matrix
% start:          Source node index;
% target:         Destination node index;
%
%OUTPUTS: 
% path:       Optimal path from start to target node
% path_cost:  Cost of traveling from start to target
%
%Inspired by:
% a) "dijkstra very simple" by Jorge Barrera:
%    http://www.mathworks.com/matlabcentral/fileexchange/14661-dijkstra-very-simple
% b) "A solution to the Maze problem with Dijkstra" - for those without the bioinformatics toolbox:
%    http://www.mathworks.com/matlabcentral/fileexchange/46072-a-solution-to-the-maze-problem-with-dijkstra
% 
%Personal note: I would like to thank Jorge Barrera for his wonderful
% example. All I did was to add support for sparse Matrices. This supports
% non-sparse matrices. Simply make sure to set "assumed zero entries" or
% disconected nodes to inf
%
% No support for disconnected nodes (node is unreachable from all neighbors)
% No support for zero weighted edges

n=size(DistanceMatrix,1);%number of nodes in the networ
S(1:n) = 0;     %s, vector, set of visited vectors
dist(1:n) = inf;   % it stores the shortest distance between the source node and any other node;
prev(1:n) = n+1;    % Previous node, informs about the best previous node known to reach each  network node 

%% pick start node by setting it to zero
dist(start) = 0;

while sum(S)~=n
    %% find next best node
    candidate = inf(1, n);
    candidate(~S) = dist(~S);%only consider non-visted nodes as candidates
    [cadidate_cost,u]=min(candidate);
    
    if ( isinf(cadidate_cost) )
        error('There are inaccessible vertices from source or zero weighted edges');
    end
    
    %% mark next best candidate node as visited
    S(u)=1;
    %% Calc cost of moving to the candidate node - if this is possible
    %find possible connections from node "s_index"
    cols = find(DistanceMatrix(u,:));
    cost_i = full(DistanceMatrix(u,cols));%cost of moving to from s_index->i

    %check connecting nodes to see if they are a better option
    new_travel_cost  = dist(u) + cost_i;
    prev_travel_cost = dist(cols);
    
    is_new_better = new_travel_cost < prev_travel_cost;
    dist(cols(is_new_better)) = new_travel_cost(is_new_better);
    prev(cols(is_new_better)) = u;%mark nodes as part of travel sequence
    
end

%% find shortest path
path = target;%Init
%backtrack from end to start to find best sequence
while path(1) ~= start
    if prev(path(1))<=n
        path=[prev(path(1)) path];
    else
        error;
    end
end;

%final cost
path_cost = dist(target);