%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Poisson point process-based spatial model
%
% Description: generating random points in square area
%
% Function parameter:
% -radiusCell: observed cell radius [m]
% -nodeDensity: intensity of nodes
%
% Function return value:
% -p: the x,y coordinates of nodes in the network
% -N: total number of nodes in the network
%
% File: SpatialModel_PPP.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p] = SpatialModel_PPP(radiusCell,N)

p = [];
angles = rand(1,N)*2*pi;
radius = radiusCell * sqrt(rand(1,N));
x = radius.*cos(angles);
y = radius.*sin(angles);
p = [x' y'];

end
