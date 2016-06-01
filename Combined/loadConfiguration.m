function [enb, ue, pdsch, pusch, timers, pdcchInformation, maxReports] = loadConfiguration(Parameters)
BW = Parameters.system.BW;
% Please configure the following parameters as desired.

%% eNodeB Parameters
enb.NDLRB         = BW;
enb.CellRefP      = 1;
enb.NSubframe     = 0;
enb.CFI           = 3;      
enb.Ng            = 'Sixth'; % Do not change

%% UE Parameters
ue.something = 'Not implemented yet';
ue.NULRB = BW;
Parameters.ue = ue;

%% PDSCH Parameters
prbs              = (0:enb.NDLRB-1).';
pdsch.NTxAnts     = 1;
pdsch.NLayers     = 1;
pdsch.TxScheme    = 'Port0';
pdsch.Modulation  = {'QPSK'};
Parameters.pdsch  = pdsch;

%% PUSCH Parameters
pusch.something = 'Not implemented yet';
Parameters.pusch = pusch;

%% Timers Parameters (given in subframes)
timers = struct ( ... 
    'rar',                   10, ... 
    'rrc_request',           40, ... % (Typical 40ms see Ultra Workshop Paper) Contention Resolution Timer: broadcasted in SIB2. If the UE doesn't receive msg4 (Contention Resolution message) within this timer, then it go back to Step 1. In addition T300 is also started.
    'rrc_connect',           40, ...
    'rrc_complete',          40, ...
    'rrc_reconfigurationdl', 40, ...
    'rrc_reconfigurationul', 40, ...
    'security_command',      40, ...
    'security_complete',     40, ...
    'data',                  40  ...
);

%% PDCCH Information
load('pdcchInformation.mat');
pdcchInformation = pdcchInfo(enb.NDLRB-5,enb.CFI); % pdcchInfo starts for 6RBs, therefore we need the -5 offset...

%% Max Reports
% We expect an average of the arrival rate messages per second, so during
% this simulaiton we can expect the following (overestimation of 2\lambda
% (Poisson variance!)
maxReports = round(10 * max(Parameters.traffic.arrivalRate) * Parameters.system.simulationLen * Parameters.system.tdma);

end