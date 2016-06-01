% matlabpool close force
% % parpool(4)
% matlabpool(12)
close all
clear variables
%rng(1)
%% Traffic
% ID    pop%    payloadstart    payload cutoff     alpha     arrivalrate
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
% 'netCmd', [ ...
% 1   40  20  20     0     1/(60*60*24);...
% 2   40  20  20     0     1/(60*60*2); ...
% 3   15  20  20     0     1/(60*60); ...
% 4   5   20  20     0     1/(60*30); ...
%     ], ...
% 'softUpdate', [ ...
% 1   100     200     2000    1.5     1/(60*60*24*180) ...
%     ] ...
% );

%% Simulation Parameters
Parameters.system = struct( ...
    ... % --- System Parameters --- %
    'tdma',              10^-3,   ...   % Slot duration  (subframe)
    'BW',                    6,   ...   % System Bandwidth in RBs
    'simulationLen',     50000,   ...   % Simulation Length in ms
    'L',                     4,   ...   % Max Data retransmissions  
    'processingTime',        0,   ...   % Processing time at the both at eNodeB and UE side
    'Rate',                1/3,   ...   % Coding Rate for Transport Block
    'dataModulation', modulation.QPSK,    ...   % Modulation used for data transmission 
    'B',                    10    ... % max number of packets bundled together
);

Parameters.lora = struct( ...
    ... % --- System Parameters --- %
    'tdma',              10^-3,   ...   % Slot duration  (subframe)    
    'simulationLen',     50000,   ...   % Simulation Length in ms
    'Bdata',                    50+12,    ... % max number of packets bundled together
    'BW',             125*10^3,     ...
    'nCH',                  16,     ...
    'SFs',                  7:12,   ...
    'SFsB', [222,222,115,51,51,51]+12, ...
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
    'headerSize',           65,  ... % Data size in bytes
    'lagLimit',            10,   ...  % latency limit in sec for regular traffic
    'lagLimitException',    1,   ...   % latency limit in sec for exception type traffic
    'exception',		    1,	 ... % Model exception (beta traffic)
    'poisson',              0,   ... % Model regular (poisson traffic)
    'alarmWaveSpeed',       0,   ... % in m/s
    'eventCentre',    [500,0],   ...
    'period',			   10,   ... % Period for beta distributed arrivals in seconds
    'offset',			    0,	 ... % Exception 'trigger' offset in seconds
    'cellRadius',		 1000,	 ... % cell radius in meters (for generating device positions)
    'clusterRadius',       10,   ... % device cluster radius    
    'aggregators',          0,   ... % 1 is aggregatos ON
    'deviceModel',       'PPP'   ...
);

Parameters.rach = struct( ...
    'backoff',                      20,  ...   % Backoff in subframes
    'PREAMBLES',                    54,  ...   % Number of Preambles
    'M',                            10,  ...   % Maximum RACH Transmissions
    'RACH',      [1,0,0,0,0,0,0,0,0,0]   ...   % Allowed subframes for RACH
);

Parameters.stats = struct( ...
    'noRRC',                  0,   ...
    'noRA',                   0,   ...
    'txErrors',             0,   ...
    'notenoughCCEs',        0,   ...
    'notenoughRBs',         0,   ...
    'correctMSG3',          0,   ...
    'collidedMSG3',         0,   ...
    'expiredMSG',           0,   ...
    'noTX',                 0,   ...
    'RRCnoTX',              0,   ...
    'RRCtxErrors',             0,   ...
    'RRCnotenoughCCEs',        0,   ...
    'RRCnotenoughRBs',         0,   ...
    'RRCcorrectMSG3',          0,   ...
    'RRCcollidedMSG3',         0,   ...
    'RRCexpiredMSG',           0,   ...    
    'usedPRBs_UL',          zeros(1,Parameters.system.simulationLen),  ...
    'usedPRBs_DL',          zeros(1,Parameters.system.simulationLen),  ...
    'usedPHYs',            -1*ones(1,Parameters.system.simulationLen) ...
);

Parameters.phy = struct( ...
    'freqDL',        865, ...     %Band 18: EARFCN: 5900 DL
    'freqUL',        865, ...     % 
    'shadowMean',    0, ...     % shadowing mean in dB
    'shadowVar',     3, ...     % shadowing variance in dB
    'raylVar',       0.5, ...     % rayleigh parameter
    'eNBpow',        30-30, ...    % enB transmission power in dBW
    'UEpow',         23-30, ...    % UE transmission power in dBW
    'noise',         -121.45-30,  ...  % noise power in dBW  
    'bitErrorTarget', 0.5*10^(-4) ...
);

fragThreshold       = ceil(1 * Parameters.system.BW);
Parameters.options  = struct(         ...
    'runIdealLink',                0, ...    
    'runIdealMAC',                 0, ...     % 0 - MAC limitations enabled | 1 - No MAC limitations (i.e., PDSCH infinite)
    'runIdealPHY',                 0, ...     % 0 - PHY limitations enabled | 1 - No PHY limitations (i.e., PDCCH infinite)
    'fragThreshold',   fragThreshold, ...     % Maximum MAC PDU size per subframe in Resource Blocks
    'phyCapacity',                 0, ...     % Number of PHY Messages per subframe (0 for actual value according to the enb parameters)
    'sequence',               'full'  ...     % Options: full - For all messages in the access procedure | shor - fort up to msg4.
);

Parameters.Aggregators=struct(      ...
    'distro',                       0, ... %distrobution of aggregaters: 0 => PPP, other => New scheme
    'link',                         0, ... %UE to AGG connection: 1 means modelled, 0 is no model/cabled
    'TargetSNR',                    0, ...
    'TXpow',                       -7, ... % UE tx power in dB
    'noise',                  -114-30, ...
    'freq',                      3000, ... % frequency in MHz
    'TXsize',                     100  ...
);

[Parameters.enb, Parameters.ue, Parameters.pdsch, Parameters.pusch, Parameters.timers, Parameters.pdcchInfo, Parameters.maxReports] = loadConfiguration(Parameters);
Parameters.timers.RLCexpire = 100; %(RLC connection expiration in X ms)

experimentName = 'PPPbeta';



%% Main Function
warning(' Poisson Arrivals Discarded For Optimization in generateTraffic.m');
tic

% Initialize
REPS          = 20;
Nd_vector     = 52200;%[0.5,1,2.5,5]*1000;               %Number of devices
Nd_vector     = sort(Nd_vector,'descend');
Na_vector     = [1:10,100,1000]; %aggregators/clusters when agg is OFF
Parameters.maxReports = 20;

saveSize      = max(numel(Nd_vector),numel(Na_vector));
active        = zeros(1,saveSize);
outage        = zeros(1,saveSize);
failures      = zeros(1,saveSize);
probCollision = zeros(1,saveSize);
lagOut        = zeros(1,saveSize);
latency       = zeros(1,saveSize);
throughput    = zeros(1,saveSize);
goodput       = zeros(1,saveSize);
usageUL  = zeros(1,saveSize);
usageDL  = zeros(1,saveSize);
latencies     = repmat({zeros(1,length([10:20:(10/Parameters.system.tdma)]))},1,saveSize);
efficiency     = zeros(1,saveSize);
PhyFailures     = zeros(1,saveSize);
MacFailures     = zeros(1,saveSize);
txErrs      = zeros(1,saveSize);
txNotErrs   = zeros(1,saveSize);%notErrors
correctMSG3     = zeros(1,saveSize);
collidedMSG3     = zeros(1,saveSize);
expiredMSG = zeros(1,saveSize);
queueLatency = zeros(1,saveSize);   % latency from queue to success
noUnf = zeros(1,saveSize);  % failures/unfinished from queue to success
noDone = zeros(1,saveSize); % finished from queue to success
usedRBs = repmat({zeros(1,Parameters.system.simulationLen)},1,saveSize);
noRRC     = zeros(1,saveSize);
noRA     = zeros(1,saveSize);
RRCtxErrs      = zeros(1,saveSize);
RRCexpiredMSG = zeros(1,saveSize);
RRCPhyFailures     = zeros(1,saveSize);
RRCMacFailures     = zeros(1,saveSize);
stateCon = zeros(1,saveSize);
stateRx = zeros(1,saveSize);
stateTx = zeros(1,saveSize);
noTX = zeros(1,saveSize);
RRCnoTX = zeros(1,saveSize);
LoRaTXs = zeros(1,saveSize);
LoRaSuccesses = zeros(1,saveSize);
LoRalatencies = cell(1,saveSize);
LoRameanlag = zeros(1,saveSize);
LoRaFailures = zeros(1,saveSize);


for i = 1:length(Na_vector)
    %prepare buffers
    parbuf = struct;

    for j=1:REPS
        % Run simulation
        [USERS_LTE,USERS,usedPRBs,dataPRBs,activeAgg, outParameters] = worker(Na_vector(i), Nd_vector, Parameters,REPS);

        % Process results
        parbuf = processResults(parbuf, USERS_LTE, usedPRBs, dataPRBs, outParameters);
%         parBufLoRa = processResults(parBufLoRa,USERS);
        
        LoRaTXs(i) = LoRaTXs(i)+sum([USERS.reportArrivals] > 0 );
        LoRaSuccesses(i) = LoRaSuccesses(i)+sum([USERS.reportSuccesses] > 0 );
        lagbuf=[USERS.reportSuccesses]-[USERS.reportArrivals];
        LoRalatencies(i) = {[LoRalatencies{i} lagbuf(lagbuf>0)]};
        LoRameanlag(i) = LoRameanlag(i) + sum(lagbuf(lagbuf>0))/sum(lagbuf>0);
        LoRaFailures(i) = LoRaFailures(i)+sum([USERS.reportFailures] > 0 );
        
        % Save stats
        latenciesBuf = parbuf.latenciesBuf;
%         latenciesBuf(latenciesBuf<=0) = []; %remove for now
        times = [10:20:(10/Parameters.system.tdma)];
        latencies(i) = {cell2mat(latencies(i)) + hist(latenciesBuf,times)};

        active(i)       = active(i) + activeAgg;
        latency(i)      = latency(i) + parbuf.latencyBuf;
%         outage(i)       = outage(i) + parbuf.outageBuf;
%         throughput(i)   = throughput(i) + parbuf.throughputBuf;
%         goodput(i)      = goodput(i) + parbuf.goodputBuf;
        usageUL(i)      = usageUL(i) + parbuf.usageULBuf;
        usageDL(i)      = usageDL(i) + parbuf.usageDLBuf;
%         lagOut(i)       = lagOut(i) + parbuf.lagOut;
        failures(i)     = failures(i) + parbuf.failuresBuf; 
        probCollision(i)= probCollision(i) + parbuf.probCollisionBuf;
%         efficiency(i)   = efficiency(i) + parbuf.efficiencyUL;
        PhyFailures(i)  = PhyFailures(i) + outParameters.stats.notenoughCCEs;
        MacFailures(i)  = MacFailures(i) + outParameters.stats.notenoughRBs;
        txErrs(i)   = txErrs(i) + outParameters.stats.txErrors;
%             txNotErrs(i) = txNotErrs(i) + notErrors;
        correctMSG3(i)  = correctMSG3(i) + outParameters.stats.correctMSG3;
        collidedMSG3(i) = collidedMSG3(i) + outParameters.stats.collidedMSG3;
        expiredMSG(i)   = expiredMSG(i) + outParameters.stats.expiredMSG;
        queueLatency(i) = queueLatency(i) + parbuf.queueLat;

        RRCPhyFailures(i)   =   RRCPhyFailures(i)   + outParameters.stats.RRCnotenoughCCEs;
        RRCMacFailures(i)   =   RRCMacFailures(i)   + outParameters.stats.RRCnotenoughRBs;
        RRCtxErrs(i)        =   RRCtxErrs(i)        + outParameters.stats.RRCtxErrors;
        RRCexpiredMSG(i)    =   RRCexpiredMSG(i)    + outParameters.stats.RRCexpiredMSG;
        
        noUnf(i)        = noUnf(i) + parbuf.noUnf;
        noDone(i)       = noDone(i) + parbuf.noDone;
        usedRBs(i)      = {cell2mat(usedRBs(i)) + outParameters.stats.usedPRBs_UL}; 
        
        stateCon(i)     = stateCon(i) + parbuf.con;
        stateRx(i)      = stateRx(i) + parbuf.rx;
        stateTx(i)      = stateTx(i) + parbuf.tx;
            
        noRRC(i) = noRRC(i) + outParameters.stats.noRRC;
        noRA(i) = noRA(i) + outParameters.stats.noRA;
        
        noTX(i) = noTX(i) + outParameters.stats.noTX;
        RRCnoTX(i) = RRCnoTX(i) + outParameters.stats.RRCnoTX;
    end
end
LoRaTXs=LoRaTXs/REPS;
LoRaSuccesses=LoRaSuccesses/REPS;
LoRaFailures=LoRaFailures/REPS;
LoRameanlag=LoRameanlag/REPS;

noTX = noTX/REPS;
RRCnoTX = RRCnoTX/REPS;

noRRC = noRRC/REPS;
noRA = noRA/REPS;

stateCon = stateCon/REPS;
stateRx = stateRx/REPS;
stateTx = stateTx/REPS;

active = active/REPS;
% outage   = outage/REPS * 100;
failures = failures/REPS * 100;
usageUL = usageUL/REPS * 100;
usageDL = usageDL/REPS * 100;
probCollision = probCollision/REPS * 100;
latency = latency/REPS;
% lagOut = lagOut/REPS * 100;
% throughput = throughput/REPS;
% goodput = goodput/REPS;
% efficiency = efficiency/REPS*100;
PhyFailures = PhyFailures/REPS;
MacFailures = MacFailures/REPS;
txErrs = txErrs/REPS;
txNotErrs = txNotErrs/REPS;

correctMSG3 = correctMSG3/REPS;
collidedMSG3 = collidedMSG3/REPS;
expiredMSG = expiredMSG/REPS;

queueLatency = queueLatency/REPS;
noUnf = noUnf/REPS;
noDone = noDone/REPS;

RRCPhyFailures  = RRCPhyFailures/REPS;
RRCMacFailures  = RRCMacFailures/REPS;
RRCtxErrs       = RRCtxErrs/REPS;
RRCexpiredMSG   = RRCexpiredMSG/REPS;

toc

clear parbuf % if not run as a parfor

%% Save Results
name = [experimentName];
datetime=datestr(now);
datetime=strrep(datetime,':','_');% Replace colon with underscore
datetime=strrep(datetime,'-','_');% Replace minus sign with underscore
datetime=strrep(datetime,' ','_');% Replace space with underscore
save(['Results/',name,'_',datetime]);

load gong.mat;
soundsc(y);