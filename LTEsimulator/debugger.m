Index = [USERS.reportIndex];

arrivalsIndex = zeros(length(Index),Parameters.maxReports);
unaccountedArrivals = zeros(length(Index),Parameters.maxReports);
for i = 1:length(Index)
    arrivalsIndex(i,Index(i)+1:Parameters.maxReports) = ones(Parameters.maxReports-Index(i),1);
    arrivals = USERS(i).reportArrivals;
    unaccountedArrivals(i,:) = arrivals.*arrivalsIndex(i,:);
    
    success = USERS(i).reportSuccesses;
    winChecker(i,:) = success.*arrivalsIndex(i,:);
    fail = USERS(i).reportFailures;
    failChecker(i,:) = fail.*arrivalsIndex(i,:);
end

nWin = sum(sum(winChecker>0))
nFail = sum(sum(failChecker>0))

nUnacc = sum(sum(unaccountedArrivals>0))-nWin-nFail
nTotal = sum(sum([USERS.reportArrivals]>0))

outUnacc = nUnacc/nTotal*100
failedIDs = sort(unique(mod(find((unaccountedArrivals>0) & ~(winChecker>0) & ~(failChecker>0)),numel(USERS))));
failedIDs(failedIDs==0)=length(Index)