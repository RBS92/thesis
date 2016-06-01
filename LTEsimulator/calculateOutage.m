function outage = calculateOutage(USERS, Parameters)

arrivals = [USERS.reportArrivals]>0; 
successes= [USERS.reportSuccesses]>0;
outage = 1 - sum(successes)/sum(arrivals);

% betas = [USERS.reportArrivalTypes] == 'B';
% poisson = [USERS.reportArrivalTypes] == 'P';
% 
% betaOutage = 1 - sum(successes(betas))/sum(arrivals)
% poissonOutage = 1 - sum(successes(poisson))/sum(arrivals)

end