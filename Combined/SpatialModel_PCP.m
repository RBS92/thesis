%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Poisson cluster process-based spatial model
%
% Description: generating random points in square area
%
% Function parameter:
% -radiusCell: observed cell radius [m]
% -headerDensity: intensity of headers
% -nodeDensity: intensity of nodes
% -radiusCluster: radius of cluster
%
% Function return value:
% -p: the x,y coordinates of nodes in the network
% -C: the x,y coordinates of cluster header in the network
% -N: total number of nodes in the network
% -Nc: total number of aggregators in the network
%
% File: SpatialModel_PCP.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p, C] = SpatialModel_PCP(radiusCell, N, radiusCluster, Nc)

% draw cluster headers
% Nc = poissrnd(headerDensity*pi*radiusCell^2);          % number of headers
C = [];
angles = rand(1,Nc)*2*pi;
radius = radiusCell * sqrt(rand(1,Nc));
x = radius.*cos(angles);
y = radius.*sin(angles);
C = [x' y'];

% N = 0;                                              % total number of nodes
p = [];
x_ = [];
y_ = [];
for c=1:Nc
    NinC = poissrnd(N/Nc);    % number of points in cluster
    angles = rand(1,NinC)*2*pi;
    dist = radiusCluster*sqrt(rand(1,NinC));
    x_ = [x_ C(c,1) + dist.*cos(angles)];
    y_ = [y_ C(c,2) + dist.*sin(angles)];
    N = N + NinC;
end
p = [x_'  y_'];

end

