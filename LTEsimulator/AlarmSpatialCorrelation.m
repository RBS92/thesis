% Parameters.traffic.alarmWaveSpeed = 150;
figure
ang=0:0.01:2*pi; 
r = 1000;
xp=r*cos(ang);
yp=r*sin(ang);
plot(xp,yp,'black');
cr = 200;
N = 65;
Nc = 7;
posDevices = SpatialModel_PPP(r,N);
% [posDevices, posClusters] = SpatialModel_PCP(r,N,cr,Nc);
% 
hold on
% for i=1:length(posClusters)
%     xp(i,:)=posClusters(i,1)+cr*cos(ang);
%     yp(i,:)=posClusters(i,2)+cr*sin(ang);
% end

% triggerPos = [500,0];
% scatter(500,0,'black','d')
scatter(posDevices(:,1),posDevices(:,2),'blue')
% plot(xp',yp','green');
legend('Cell border','Device','Cluster border')
% 
% 
% distancesToAlarmTrigger = sqrt((triggerPos(1)-posDevices(:,1)).^2+(triggerPos(2)-posDevices(:,2)).^2);
% 
% alarm = [ceil(0+distancesToAlarmTrigger'/Parameters.traffic.alarmWaveSpeed/Parameters.system.tdma)];

% legend('Cell border','Alarm event','M2M device')

% % for T = 0:1000:10000
% T = 10000
% %     pause
%     figure
%     plot(xp,yp,'black');
%     hold on
%     scatter(500,0,'black','d')
%     scatter(posDevices(:,1),posDevices(:,2),'blue')
%     
%     I = find(alarm<=T);
%     scatter(posDevices(I,1),posDevices(I,2),'red')
%     legend('Cell border','Alarm event','M2M device','Alarm triggered')
% % end
% 
% [y,x] = hist(alarm,100);
% plot(x,y/sum(y))
% 
% alarmperiod = max(alarm)
% phat = betafit(alarm/alarmperiod)
% 
% y = alarmperiod*betarnd(phat(1),phat(2),1,100000);
% 
% [y,x]=hist(y,100);
% hold on
% plot(x,y/sum(y),'red')