function [USERS_LTE,USERS,usedPRBs,dataPRBs,activeAgg,Parameters] = worker(Ns, Nd, Parameters,REPS)

% Initialize
UE = struct(...
      'reportEarlyFailures', zeros(1,Parameters.maxReports), ...
      'reportEarlyFailureTypes', zeros(1,Parameters.maxReports), ...
      'reportArrivals' ,     zeros(1,Parameters.maxReports), ...
      'reportDatasize' ,     zeros(1,Parameters.maxReports), ...
      'SFs' ,     zeros(1,Parameters.maxReports), ...
      'CHs' ,     zeros(1,Parameters.maxReports), ...
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
      'bundleIndex'    ,    zeros(1, Parameters.maxReports), ...
      'con'            ,                                  0, ...
      'rx'             ,                                  0, ...
      'tx'             ,                                  0,  ...
      'capture',    0 ...
);
loRAMax = Parameters.maxReports;
Parameters.maxReports = ceil(10000/Ns);
lteMax = Parameters.maxReports;
UE2 = struct(...
      'reportEarlyFailures', zeros(1,Parameters.maxReports), ...
      'reportEarlyFailureTypes', zeros(1,Parameters.maxReports), ...
      'reportArrivals' ,     zeros(1,Parameters.maxReports), ...
      'reportDatasize' ,     zeros(1,Parameters.maxReports), ...
      'SFs' ,     zeros(1,Parameters.maxReports), ...
      'CHs' ,     zeros(1,Parameters.maxReports), ...
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
      'bundleIndex'    ,    zeros(1, Parameters.maxReports), ...
      'con'            ,                                  0, ...
      'rx'             ,                                  0, ...
      'tx'             ,                                  0,  ...
      'capture',    0 ...
);
Parameters.maxReports =loRAMax;

%% Indicate Random Access Opportunity (RAO)
RAO = repmat(Parameters.rach.RACH, 1, Parameters.system.simulationLen+5000); 

%% Load initial premables (optimization)
% if(Parameters.traffic.aggregators)
    Preambles = round(rand(round(1.1*Ns),Parameters.rach.M)*(Parameters.rach.PREAMBLES-1))+1; % This is a matrix with 1:M columns and 1:total_users rows.
%     USERS = repmat (UE,1,Ns);
%     USERS_LTE = repmat (UE,1,Ns);
% else
%     Preambles = round(rand(round(1.1*Nd),Parameters.rach.M)*(Parameters.rach.PREAMBLES-1))+1; % This is a matrix with 1:M columns and 1:total_users rows.
    USERS = repmat (UE,1,Nd);
    USERS_LTE = repmat (UE2,1,Ns);
% end

%% Generate Reports and Load Initial RACH Values
%USERS = repmat (UE,1,Ns);
% [USERS,activeAgg] = generateTraffic(USERS,Ns, Nd, Preambles, RAO, Parameters);
% [USERS,activeAgg] = generateTraffic(USERS,Ns, Nd, Parameters);
[USERS_LTE,USERS,nodeAssocWith,activeAgg] = generateTraffic(USERS_LTE, USERS, Ns, Nd, Parameters);

%% Lora
startSF = Parameters.lora.SFs(1);
nCH = Parameters.lora.nCH;
TXs=zeros(1,numel(Nd));
Successes=zeros(1,numel(Nd));
Failures=zeros(1,numel(Nd));
meanlag=zeros(1,numel(Nd));
latencies = cell(1,numel(Nd));
SFs = cell(1,numel(Nd));

for i = 1:numel(Nd)
%     sfsindex = ceil(rand(1,N(i))*numel(SFs));
%     sfs = SFs(sfsindex);
%     USERS = repmat(UE,1,Nd(i));

    txs = [USERS.nextTX];
    txIDs = find(txs ~= 0);
%         nTXs = sum(txs ~= 0);

%         sfs = ceil(rand(1,nTXs)*nSFs)+startSF-1;
%         chs = ceil(rand(1,nTXs)*nCH);
    for j = 1:numel(txIDs)
        ID = txIDs(j);
        reportIndex = USERS(ID).reportIndex;

        dataSize = USERS(ID).reportDatasize(reportIndex)+12;
        avail = (Parameters.lora.Bdata <= Parameters.lora.SFsB);
        nSFs = sum(avail);
        SF = ceil(rand*nSFs)+startSF-1;
        CH = ceil(rand*nCH);
        USERS(ID).SFs(reportIndex) = SF;
        USERS(ID).CHs(reportIndex) = CH;
        [C] = capacity(SF,2,Parameters.lora.BW);
        Rs = Parameters.lora.BW./(2.^SF); %symbol rate
        txpreamp = 8./Rs*1000;

        txTime = dataSize*8/C*1000+txpreamp;


        USERS(ID).reportSuccesses(reportIndex) = USERS(ID).reportArrivals(reportIndex)+txTime;

        USERS(ID).reportIndex = reportIndex+1;
        nextTX = USERS(ID).reportArrivals(reportIndex+1);
        if(nextTX<USERS(ID).reportSuccesses(reportIndex))
            if(nextTX)
                nextTX = ceil(USERS(ID).reportSuccesses(reportIndex))+1;
            end
        end
        USERS(ID).nextTX = nextTX;
    end

    for j = 1:nCH
        for k = Parameters.lora.SFs
            index = find(([USERS.CHs] == j).*([USERS.SFs] == k));
            arrivals = [USERS.reportArrivals];
            ends = [USERS.reportSuccesses];
            arrivals = arrivals(index);
            ends = ends(index);

            for l = 1:numel(arrivals)
                col = (arrivals(l)<ends([1:l-1 l+1:end])).*(arrivals([1:l-1 l+1:end])<ends(l));
                if(any(col))
                    SecID = find(col);
                    SecID(SecID >= l) = SecID(SecID >= l)+1;
                    SecID = ceil(index(SecID)/Parameters.maxReports);
                    PrimID = ceil(index(l)/Parameters.maxReports);
                    
                    PrimPos = USERS(PrimID).pos;
                    PrimRXID = nodeAssocWith(PrimID);
                    PrimRXpos = USERS_LTE(PrimRXID).pos;
                    SecPos = USERS(SecID).pos;
%                     SecRXID = nodeAssocWith(SecID);
%                     SecRXpos = USERS_LTE(SecRXID).pos;
                    
                    SecDist = sqrt(sum((PrimRXpos-SecPos).^2));
                    PrimDist = sqrt(sum((PrimRXpos-PrimPos).^2));
                    
                    SecPL = 10 * Parameters.lora.n * log10(SecDist);
                    PrimPL = 10 * Parameters.lora.n * log10(PrimDist);
                    
                    SecRXPow = Parameters.lora.Ptx - SecPL;
                    PrimRXPow = Parameters.lora.Ptx - PrimPL;
                    
                    %capture effect (IF one dBm greater!)
                    capture = (PrimRXPow-SecRXPow)>=1;
%                     (PrimRXPow-SecRXPow)
                    %successful reception if strong starts at most 3 
                    %symbols after weak starts
                    Rs = Parameters.lora.BW./(2.^k); %symbol rate
                    txlimit = 3./Rs*1000;
                    arrivalbuffer = arrivals([1:l-1 l+1:end]);
                    success = (arrivals(l)+txlimit<= arrivalbuffer(find(col)));
                    
                    ID = ceil(index(l)/Parameters.maxReports);
                    if(all(capture) && all(success))
%                         SecRXPow
%                         PrimRXPow
%                         PrimPos
%                         SecPos
%                         PrimRXpos
                        USERS(ID).capture = USERS(ID).capture+1;%numel(capture);
                    else % lost due to collission
%                         l
%                         index
%                         index(l)
                        reportIndex = mod(index(l),Parameters.maxReports);
                        USERS(ID).reportFailures(reportIndex) = USERS(ID).reportSuccesses(reportIndex);
                        USERS(ID).reportSuccesses(reportIndex) = 0;
                        SFs{i} = [SFs{i} USERS(ID).SFs(reportIndex)];
                    end
                end
            end
        end
    end
end

%
USERS_LTE = nextstruct(USERS_LTE,USERS,nodeAssocWith,Preambles,RAO);

%% Simulate System
Parameters.maxReports = lteMax;
% Parameters.system.simulationLen = Parameters.system.simulationLen + 5000;
[USERS_LTE,usedPRBs,dataPRBs, Parameters] = simulateSubframes(USERS_LTE, RAO, Parameters);
% Parameters.system.simulationLen = Parameters.system.simulationLen - 5000;
% usedPRBs = 0;
% dataPRBs = 0;
end
