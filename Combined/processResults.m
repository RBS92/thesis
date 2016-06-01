function parbuf = processResults(parbuf, USERS, usedPRBs, dataPRBs, Parameters)

% [parbuf.latencyBuf, parbuf.latenciesBuf, parbuf.outageBuf, parbuf.failuresBuf, parbuf.probCollisionBuf, parbuf.lagOut,  ...
%  parbuf.throughputBuf, parbuf.goodputBuf, parbuf.usageULBuf, ...
%  parbuf.usageDLBuf, parbuf.efficiencyUL, parbuf.avgLat, parbuf.noUnf, parbuf.noDone] = calculateLatency(USERS, usedPRBs,dataPRBs, Parameters);

startTimes = [USERS.reportArrivals];
endTimes = [USERS.reportSuccesses];
% types = [USERS.reportArrivalTypes];

latencies = endTimes-startTimes;

meanlatency = sum(latencies(latencies > 0))/sum(latencies > 0);
parbuf.latencyBuf = meanlatency;

latencies(latencies == 0) = [];
latencies(latencies < 0) = -1;
parbuf.latenciesBuf = latencies;

rachCol = sum(sum([USERS.rachCollisions]>0))/sum(sum(startTimes>0));

SuccesRatio     = (sum(sum(endTimes>0))/sum(sum(startTimes>0)) );
% lagOut  = (sum(betaLatencies>Parameters.traffic.lagLimitException*10^3) + sum(poissonLatencies>Parameters.traffic.lagLimit*10^3))/(sum(endTimes>0));
% outage  = 1-(SuccesRatio*(1-lagOut));%lagOut + Out % find as an percentage
failures = 1-SuccesRatio;
% parbuf.outageBuf = outage;
parbuf.failuresBuf = failures;
parbuf.probCollisionBuf = rachCol;
% parbuf.lagOut = lagOut;

usedPRBs_UL = usedPRBs(1,:);
usedPRBs_DL = usedPRBs(2,:);
usageUL = sum(usedPRBs_UL)/(Parameters.ue.NULRB*numel(usedPRBs_UL) - floor(numel(usedPRBs_UL)/10*sum(Parameters.rach.RACH))*6);
usageDL = sum(usedPRBs_DL)/(Parameters.enb.NDLRB*numel(usedPRBs_DL));
parbuf.usageULBuf = usageUL;
parbuf.usageDLBuf = usageDL;

avgLat = [USERS.reportSuccesses]-[USERS.reportArrivals];
noUnf = sum(avgLat<0);
noDone = sum(avgLat>0);
avgLat = sum(avgLat(avgLat>0))/sum((avgLat>0));
parbuf.avgLat = avgLat;
parbuf.noUnf = noUnf;
parbuf.noDone = noDone;

queued = [USERS.reportQueued];
buf = (queued-startTimes).*(endTimes>0);
parbuf.queueLat = sum(buf(queued>0))/sum(endTimes>0);
% parbuf.queueLat = sum(queueLat(startTimes>0))/sum(startTimes>0);

parbuf.con = sum([USERS.con]);
parbuf.rx = sum([USERS.rx]);
parbuf.tx = sum([USERS.tx]);