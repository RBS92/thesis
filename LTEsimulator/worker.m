function [USERS,usedPRBs,dataPRBs,activeAgg,Parameters] = worker(Ns, Nd, Parameters)

% Initialize
UE = struct(...
      'reportEarlyFailures', zeros(1,Parameters.maxReports), ...
      'reportEarlyFailureTypes', zeros(1,Parameters.maxReports), ...
      'reportArrivals' ,     zeros(1,Parameters.maxReports), ...
      'reportDatasize' ,     zeros(1,Parameters.maxReports), ...
      'reportArrivalTypes',  repmat('N',1,Parameters.maxReports), ...
      'reportSuccesses',     zeros(1,Parameters.maxReports), ...
      'reportFailures' ,     zeros(1,Parameters.maxReports), ...
      'rachCollisions' ,     zeros(1,Parameters.maxReports), ...
      'reportQueued'   ,     zeros(1,Parameters.maxReports), ...
      'reportRACHtx'   ,     zeros(1,Parameters.maxReports), ...
      'msgType'        ,     zeros(1,Parameters.maxReports), ...
      'reportTXs'      ,      ones(1,Parameters.maxReports), ...
      'reportRachTXs'  ,      ones(1,Parameters.maxReports), ...
      'reportCumTXs'   ,      zeros(1,Parameters.maxReports), ...
      'preambleTXs'    ,      ones(1,Parameters.maxReports), ...
      'PREAMBLES'      ,         zeros(1,Parameters.rach.M), ...
      'lastMessage'    ,                                 '', ...
      'applicationID'  ,                                  0, ...
      'reportIndex'    ,                                  1, ...
      'nextTX'         ,                                  0, ...
      'nextRACH'       ,                                  0, ...
      'nextPreamble'   ,                                  0, ...
      'RLC'            ,                                  0, ...
      'RLCexpiration'  ,                                  0, ...
      'failedToAgg'    ,                                  0, ...
      'pos'		       ,                         zeros(1,2), ...
      'bundleIndex'    ,    zeros(1, Parameters.maxReports),  ...  
      'con',                  0,   ...
      'rx',                   0,   ...
      'tx',                   0,   ...
      'txing',                0    ...
);
        

%% Indicate Random Access Opportunity (RAO)
RAO = repmat(Parameters.rach.RACH, 1, Parameters.system.simulationLen); 

%% Load initial premables (optimization)
if(Parameters.traffic.aggregators)
    Preambles = round(rand(round(1.1*Ns),Parameters.rach.M)*(Parameters.rach.PREAMBLES-1))+1; % This is a matrix with 1:M columns and 1:total_users rows.
    USERS = repmat (UE,1,Ns);
else
    Preambles = round(rand(round(1.1*Nd),Parameters.rach.M)*(Parameters.rach.PREAMBLES-1))+1; % This is a matrix with 1:M columns and 1:total_users rows.
    USERS = repmat (UE,1,Nd);
end

%% Generate Reports and Load Initial RACH Values
%USERS = repmat (UE,1,Ns);
[USERS,activeAgg] = generateTraffic(USERS,Ns, Nd, Preambles, RAO, Parameters);

%% Simulate System
[USERS,usedPRBs,dataPRBs, Parameters] = simulateSubframes(USERS, RAO, Parameters);

end
