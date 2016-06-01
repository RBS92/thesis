clear all
close all
clc

%% LoRa - Analysis results


Traffic = struct(...
'MARexception', [ ... % This one is ignored when generating poisson!
1   20 0.05...
    ], ...
'MARperiodic', [ ...
1   40  20  200     2.5     1/(60*60*24); ...
2   40  20  200     2.5     1/(60*60*2); ...
3   15  20  200     2.5     1/(60*60); ...
4   5   20  200     2.5     1/(60*30); ...
    ] ...
);


Parameters.system = struct( ...
    ... % --- System Parameters --- %
    'tdma',              10^-3,   ...   % Slot duration  (subframe)    
    'simulationLen',     50000,   ...   % Simulation Length in ms
    'B',                    50,    ... % max number of packets bundled together
    'BW',             125*10^3,     ...
    'nCH',                  16,     ...
    'SFs',                  7:12,   ...
    'SFsB', [222,222,115,51,51,51], ...
    'SFsS', [-123 -126 -129 -132 -134.5 -137], ...
    'CRs', 1:4, ...
    'Ptx', 14, ...
    'Pn', -174+10*log10(125*10^3), ...
    'cell_r', 1000, ...
    'n', 4 ...
);


Parameters.traffic = struct( ...
    'Traffic',        Traffic,   ...      
    'arrivalRate',     1/(60),   ... % Arrival rate in seconds
    'headerSize',           65,   ... % Data size in bytes
    'lagLimit',            10,   ...  % latency limit in sec for regular traffic
    'lagLimitException',    1,   ...   % latency limit in sec for exception type traffic
    'exception',		    1,	 ... % Model exception (beta traffic)
    'poisson',              0,   ... % Model regular (poisson traffic)
    'alarmWaveSpeed',       0,   ... % in m/s
    'eventCentre',    [500,0], ...
    'period',			   10,   ... % Period for beta distributed arrivals in seconds
    'offset',			    0,	 ... % Exception 'trigger' offset in seconds
    'cellRadius',		 1000,	 ... % cell radius in meters (for generating device positions)
    'clusterRadius',        10,  ... % device cluster radius    
    'aggregators',          0,   ... % 1 is aggregatos ON
    'deviceModel',       'PPP'   ...
);

Parameters.maxReports = 20;


UE = struct(...
      'reportEarlyFailures', zeros(1,Parameters.maxReports), ...
      'reportEarlyFailureTypes', zeros(1,Parameters.maxReports), ...
      'reportArrivals' ,     zeros(1,Parameters.maxReports), ...
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
      'tx'             ,                                  0  ...
);

REPS = 10;
N = 52200;
avail = (Parameters.system.B <= Parameters.system.SFsB);
nSFs = numel(avail);
startSF = Parameters.system.SFs(1);
nCH = Parameters.system.nCH;

TXs=zeros(1,numel(N));
Successes=zeros(1,numel(N));
Failures=zeros(1,numel(N));
meanlag=zeros(1,numel(N));
latencies = cell(1,numel(N));
SFs = cell(1,numel(N));

for i = 1:numel(N)
    for m = 1:REPS
    %     sfsindex = ceil(rand(1,N(i))*numel(SFs));
    %     sfs = SFs(sfsindex);
        USERS = repmat(UE,1,N(i));

        [USERS] = generateTraffic(USERS, N(i), Parameters); 

        txs = [USERS.nextTX];
        txIDs = find(txs ~= 0);
        nTXs = sum(txs ~= 0);

        sfs = ceil(rand(1,nTXs)*nSFs)+startSF-1;
        chs = ceil(rand(1,nTXs)*nCH);
        for j = 1:numel(txIDs)
            ID = txIDs(j);
            reportIndex = USERS(ID).reportIndex;
            USERS(ID).SFs(reportIndex) = sfs(j);
            USERS(ID).CHs(reportIndex) = chs(j);
            [C] = capacity(sfs(j),2,Parameters.system.BW);
            txTime = Parameters.system.B/C*1000;

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
            for k = Parameters.system.SFs
                index = find(([USERS.CHs] == j).*([USERS.SFs] == k));
                arrivals = [USERS.reportArrivals];
                ends = [USERS.reportSuccesses];
                arrivals = arrivals(index);
                ends = ends(index);

                for l = 1:numel(arrivals)
                    col = any((arrivals(l)<ends([1:l-1 l+1:end])).*(arrivals([1:l-1 l+1:end])<ends(l)));
                    if(col)
                        ID = ceil(index(l)/Parameters.maxReports);
                        reportIndex = mod(index(l),Parameters.maxReports);
                        USERS(ID).reportFailures(reportIndex) = USERS(ID).reportSuccesses(reportIndex);
                        USERS(ID).reportSuccesses(reportIndex) = 0;
                        SFs{i} = [SFs{i} USERS(ID).SFs(reportIndex)];
                    end
                end
            end
        end

        TXs(i) = TXs(i)+sum([USERS.reportArrivals] > 0 );
        Successes(i) = Successes(i)+sum([USERS.reportSuccesses] > 0 );
        lagbuf=[USERS.reportSuccesses]-[USERS.reportArrivals];
        latencies{i} = [latencies{i} lagbuf(lagbuf>0)];
        meanlag(i) = meanlag(i) + sum(lagbuf(lagbuf>0))/sum(lagbuf>0);
        Failures(i) = Failures(i)+sum([USERS.reportFailures] > 0 );
    end
end

TXs=TXs/REPS;
Successes=Successes/REPS;
Failures=Failures/REPS;
meanlag=meanlag/REPS;

%% Post processing
figure
plot(N,Failures./TXs)

figure
plot(N,meanlag)

figure
[y,x] = hist(SFs{9},7:12);
bar(x,y)

% index = find(([USERS.CHs] 