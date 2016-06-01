%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Associate devices with aggregators
%
% Description: Associate devices with aggregators based on nearest neighbor rule
%
% Function parameter:
% -p: the x,y coordinates of nodes in the network
% -C: the x,y coordinates of cluster header in the network
% -N: total number of nodes in the network
% -Nc: total number of aggregators in the network
%
% Function return value:
% -assocMatrix: assocMatrix(i,j)=1 if node i is associated with aggregator j, else 0
% -nodeAssocWith: nodeAssocWith(i) returns index of aggregator associated with node i
%
% File: nearestAssocDeviceCluster.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [distances, nodeAssocWith] = nearestAssocDeviceClusterOpt(p, C, N, Nc)

% Matrix Operation for MATLAB Performance
C_XMatrix = repmat(C(:,1)', N, 1);
C_YMatrix = repmat(C(:,2)', N, 1);
p_X = repmat(p(:,1), 1, Nc);
p_Y = repmat(p(:,2), 1, Nc);


% calculate distance between devices and aggregators
distX = p_X - C_XMatrix;
distY = p_Y - C_YMatrix;

totalDist = sqrt(distX.^2 + distY.^2);
[distances, nodeAssocWith] = min(totalDist,[],2);
nodeAssocWith = nodeAssocWith';
distances = distances';


% for i=1:N
%     for j=1:Nc
%         distmx(i,j) = norm([p(i,1),p(i,2)]-[C(j,1),C(j,2)]);
%     end
%     % association based on distance
%     [dist idx] = sort(distmx(i,:));
%     nodeAssocWith(i) = idx(1);
%     assocMatrix(i,idx(1)) = 1;
% end

end

