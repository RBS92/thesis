clear all;

area_x=8.5;         % target area
area_y=10;
grid_interval=0.5;	% interval between adjacent grid points
r=1.5;              % cover range of an aggregator
waf=3.1;            % attenuation factor through the wall

% m by n grid matrix
m=ceil(area_y/grid_interval)-1;
n=ceil(area_x/grid_interval)-1; 

location=zeros(m,n);

figure(1)
axis([0 area_x 0 area_y]);
grid on

coordi_x1=grid_interval:grid_interval:(area_x-grid_interval); % all (x,y) coordination
coordi_y1=flipud((grid_interval:grid_interval:(area_y-grid_interval))'); 
coordi_x=repmat(coordi_x1,[length(coordi_y1),1]); % (x,y) coordination of grid points
coordi_y=repmat(coordi_y1,[1,length(coordi_x1),]);

cover = zeros(m,n);
aggregator_x = [];
aggregator_y = [];

for i=1:length(coordi_x1)
	for j=1:length(coordi_y1)
        if location(j,i) ~= 1
            dist = sqrt((coordi_x1(i)-coordi_x).^2 + (coordi_y1(j)-coordi_y).^2);
            temp = (dist<=r);

            cover(j,i) = sum(sum(temp));
        end
    end
end

while sum(sum(cover)) > 0
    [val idx] = max(cover); % idx(idx1) is y coordination
    [val1 idx1] = max(val); % idx1 is x coordination

    cover(idx(idx1),idx1) = 0;
    for p=1:length(coordi_x1)
        for q=1:length(coordi_y1)
            dist = sqrt((coordi_x(idx(idx1),idx1)-coordi_x).^2 + (coordi_y(idx(idx1),idx1)-coordi_y).^2);
            temp = ~(dist<=r);
        end
    end
    cover = cover .* temp;

    aggregator_x = [aggregator_x idx1];
    aggregator_y = [aggregator_y idx(idx1)];
    hold on
    scatter(coordi_x(idx(idx1),idx1), coordi_y(idx(idx1), idx1), 'r*')
end
% hold on
% for i=1:length(aggregator_y)
%     scatter(coordi_x(aggregator_y(i),aggregator_x(i)), coordi_y(aggregator_y(i), aggregator_x(i)), 'r*')
% end

clear i; clear j; clear p; clear q;
