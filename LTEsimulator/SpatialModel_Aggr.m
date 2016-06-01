%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Grid-like Spatial Model for Aggregator
%
% Description: generating points to cover entire circular area
%
% Function parameter:
% -radiusCell: observed cell radius [m]
% -radiusAggr: coverage radius of aggregator [m]
% -N: numbe of aggregators
% -gridInterval: interval between adjacent grid points
%
% Function return value:
% -p: the x,y coordinates of nodes in the network
% -N: total number of nodes in the network
%
% File: SpatialModel_Aggr.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all
function [p] = SpatialModel_Aggr(radiusCell,N,gridInterval)

% radiusCell = 1000;
% N = 20;
% gridInterval = 1;
radiusAggr = sqrt(radiusCell^2/N)*sqrt(pi);


% coordination elements
coordi_x1=0:gridInterval:2*radiusCell;
coordi_y1=flipud((0:gridInterval:2*radiusCell)');

% (x,y) coordination of grid points
[coordi_x,coordi_y]= meshgrid(coordi_x1,coordi_y1);
% coordi_x=repmat(coordi_x1,[length(coordi_y1),1]);
% coordi_y=repmat(coordi_y1,[1,length(coordi_x1)]);

% m by m grid matrix
m = length(coordi_x1);
location=zeros(m,m);
cover = zeros(m,m);
aggregator_x = [];
aggregator_y = [];

index = sqrt((coordi_x-radiusCell).^2 + (coordi_y-radiusCell).^2)<= radiusCell;
location(index) = 1;
vert = floor(radiusAggr/gridInterval);

cover = zeros(m,m);

dist = sqrt((coordi_x1(vert+1)-coordi_x).^2 + (coordi_y1(vert+1)-coordi_y).^2);
coverNum = sum(sum(dist<=radiusAggr));
cover(vert+1:end-vert,vert+1:end-vert) = coverNum;
for i = 1:vert
    dist = sqrt((coordi_x1(vert+1-i)-coordi_x).^2 + (coordi_y1(vert+1)-coordi_y).^2);
    coverNum = sum(sum(dist<=radiusAggr));
    cover([vert+1-i,end-vert+i],vert+1:end-vert) = coverNum;
    cover(vert+1:end-vert,[vert+1-i,end-vert+i]) = coverNum;
end
cover = cover.*index;

count = 0;
while (sum(sum(cover)) > 0) && (count < N)
    [val idx] = max(cover); % idx(idx1) is y coordination
    [val1 idx1] = max(val); % idx1 is x coordination

    cover(idx(idx1),idx1) = 0;
    cover1 = cover;

    dist = sqrt((coordi_x(idx(idx1),idx1)-coordi_x).^2 + (coordi_y(idx(idx1),idx1)-coordi_y).^2);
    temp = ~(dist<=radiusAggr);
                
    cover = cover .* temp;
    cover2 = cover;

    aggregator_x = [aggregator_x coordi_x(idx(idx1),idx1)];
    aggregator_y = [aggregator_y coordi_y(idx(idx1), idx1)];
    count = count + 1;
end

aggregator_x = aggregator_x - radiusCell;
aggregator_y = aggregator_y - radiusCell;

if count < N
    rest = N - count;
    [restPos] = SpatialModel_PPP(radiusCell, rest);
    aggregator_x = [aggregator_x restPos(:,1)'];
    aggregator_y = [aggregator_y restPos(:,2)'];
end
P = [aggregator_x' aggregator_y'];

% 
% figure(1)
% xlim([-radiusCell radiusCell]);
% ylim([-radiusCell radiusCell]);
% axis('square');
% grid on
% hold on
% scatter(P(:,1),P(:,2),'r*');
% sample = 50;
% t=(0:sample)*2*pi/sample;
% plot(radiusCell*cos(t), radiusCell*sin(t),'r');   
% 
% clear i; clear j; clear p; clear q;
