function Parameters = selectScenario(scenario)

Traffic = load('SimpleTraffic.m');

%% Simulation Parameters
Parameters.system = struct( ...
    ... % --- System Parameters --- %
    'tdma',              10^-3,   ...   % Slot duration  (subframe)
    'BW',                   25,   ...   % System Bandwidth in RBs
    'simulationLen',      30000,   ...   % Simulation Length in ms
    'L',                     1,    ...   % Max Data retransmissions  
    'processingTime',        3,   ...   % Processing time at the both at eNodeB and UE side
    'Rate',                1/3,   ...   % Coding Rate for Transport Block
    'peControl',             0,   ...   % Probability of error for control channel and messages.
    'peData',                0,   ...   % Probability of error fro data packets.
    'dataModulation', modulation.QPSK    ...   % Modulation used for data transmission 
);

Parameters.traffic = struct( ...
    'Traffic',                Traffic,   ...      
    'arrivalRate',       Traffic(:,3),   ... % Arrival rate in seconds
    'dataSize',                  1500    ... % Data size in bytes
);

Parameters.rach = struct( ...
    'backoff',                      20,  ...   % Backoff in subframes
    'PREAMBLES',                    54,  ...   % Number of Preambles
    'M',                            10,  ...   % Maximum RACH Transmissions
    'RACH',       [1,0,0,0,0,1,0,0,0,0]  ...   % Allowed subframes for RACH
);

fragThreshold       = 6;
Parameters.options  = struct(         ...
    'runIdealMAC',                 0, ...     % 0 - MAC limitations enabled | 1 - No MAC limitations (i.e., PDSCH infinite)
    'runIdealPHY',                 0, ...     % 0 - PHY limitations enabled | 1 - No PHY limitations (i.e., PDCCH infinite)
    'fragThreshold',   fragThreshold, ...     % Maximum MAC PDU size per subframe in Resource Blocks
    'phyCapacity',                 0, ...     % Number of PHY Messages per subframe (0 for actual value according to the enb parameters)
    'sequence',               'full'  ...     % Options: full - For all messages in the access procedure | shor - fort up to msg4.
);

%% Specific Values
switch (scenario)
    case 1
        %% 1) 1MHz Small Payload 0.5 RAOs (QPSK)
            Parameters.system.BW = 6;
            Parameters.traffic.dataSize = 100;
            Parameters.rach.RACH = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

    case 2
        %% 2) 1MHz Small Payload 1 RAOs(QPSK)
            Parameters.system.BW = 6;
            Parameters.traffic.dataSize = 100;
            Parameters.rach.RACH = [1,0,0,0,0,0,0,0,0,0];

    case 3
        %% 3) 1MHz Large Payload 0.5 RAOs(QPSK)
            Parameters.system.BW = 6;
            Parameters.traffic.dataSize = 1000;
            Parameters.rach.RACH = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

    case 4
        %% 2) 1MHz Large Payload 1 RAOs(QPSK)
            Parameters.system.BW = 6;
            Parameters.traffic.dataSize = 1000;
            Parameters.rach.RACH = [1,0,0,0,0,0,0,0,0,0];  
    
    case 5
        %% 4) 5MHz Small Payload 2 RAOs(QPSK)
            Parameters.system.BW = 25;
            Parameters.traffic.dataSize = 100;
            Parameters.rach.RACH = [1,0,0,0,0,1,0,0,0,0];
            
    case 6
        %% 4) 5MHz Small Payload 10 RAOs(QPSK)
            Parameters.system.BW = 25;
            Parameters.traffic.dataSize = 100;
            Parameters.rach.RACH = [1,1,1,1,1,1,1,1,1,1];        
                    
    case 7
        %% 6) 5MHz Large Payload 2 RAOs(QPSK)
            Parameters.system.BW = 25;
            Parameters.traffic.dataSize = 1000;
            Parameters.rach.RACH = [1,0,0,0,0,1,0,0,0,0];

     case 8
        %% 6) 5MHz Large Payload 10 RAOs(QPSK)
            Parameters.system.BW = 25;
            Parameters.traffic.dataSize = 1000;
            Parameters.rach.RACH = [1,1,1,1,1,1,1,1,1,1];

end
[Parameters.enb, Parameters.ue, Parameters.pdsch, Parameters.pusch, Parameters.timers, Parameters.pdcchInfo, Parameters.maxReports] = loadConfiguration(Parameters);
