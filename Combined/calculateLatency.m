function [latency, latencies, outage, failures, rachCol, lagOut, throughput, goodput, usageUL, usageDL, efficiencyUL,avgLat,noUnf,noDone] = calculateLatency(USERS, usedPRBs,dataPRBs, Parameters);

startTimes = [USERS.reportArrivals];
endTimes = [USERS.reportSuccesses];
types = [USERS.reportArrivalTypes]; % for specific types

% failUEfailUEtimes = [USERS.reportEarlyFailures];
% failUEfailUEtypes = [USERS.reportEarlyFailureTypes];
% 
% totalArrivals = sum(failUEfailUEtimes>0) + sum(startTimes>0);
% 
% sum(failUEfailUEtimes>0)

latencies = endTimes-startTimes;
types = types(latencies > 0);
latencies = latencies(latencies > 0);
betaLatencies = latencies(types == 'B' );
poissonLatencies = latencies(types == 'P' );


% means
latency = sum(latencies)/length(latencies);
betaLatency = sum(latencies(types == 'B'))/length(latencies(types == 'B'));
poissonLatency = sum(latencies(types == 'P'))/length(latencies(types == 'P'));

% outage
rachCol = sum(sum([USERS.rachCollisions]>0))/sum(sum(startTimes>0));
SuccesRatio     = (sum(sum(endTimes>0))/sum(sum(startTimes>0)) );
lagOut  = (sum(betaLatencies>Parameters.traffic.lagLimitException*10^3) + sum(poissonLatencies>Parameters.traffic.lagLimit*10^3))/(sum(endTimes>0));
outage  = 1-(SuccesRatio*(1-lagOut));%lagOut + Out % find as an percentage
failures = 1-SuccesRatio;

% throughput
goodLatencies = [sort(betaLatencies(betaLatencies<=Parameters.traffic.lagLimitException*10^3)),sort(poissonLatencies(poissonLatencies<=Parameters.traffic.lagLimit*10^3))];
goodput = sum(1/Parameters.traffic.dataSize*goodLatencies.*10^3);
throughput = sum(1/Parameters.traffic.dataSize*latencies)*10^3;

% efficiency
usedPRBs_UL = usedPRBs(1,:);
usedPRBs_DL = usedPRBs(2,:);
usageUL = sum(usedPRBs_UL)/(Parameters.ue.NULRB*numel(usedPRBs_UL) - floor(numel(usedPRBs_UL)/10*sum(Parameters.rach.RACH))*6);
usageDL = sum(usedPRBs_DL)/(Parameters.enb.NDLRB*numel(usedPRBs_DL));

efficiencyUL = sum(dataPRBs)/sum(usedPRBs_UL);


avgLat = [USERS.reportSuccesses]-[USERS.reportQueued];

noUnf = sum(avgLat<0);
noDone = sum(avgLat>0);

avgLat = sum(avgLat(avgLat>0))/sum((avgLat>0));
% figure; hold on;
% [y,x] = hist(latencies,10000);
% cy = cumsum(y)/sum(y);
% plot(x,cy)
% [y,x] = hist(betaLatencies,10000);
% cy = cumsum(y)/sum(y);
% plot(x,cy)
% [y,x] = hist(poissonLatencies,10000);
% cy = cumsum(y)/sum(y);
% plot(x,cy)
% xlabel('latency [ms]')
% ylabel('CDF')
% legend('All','Beta','Poisson')

