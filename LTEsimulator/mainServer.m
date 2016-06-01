clear variables
close all
clc

%% Select Scenario
disp(' ----------------------------------------- ');
disp(' |                                       | ');
disp(' |            Select Scenario            | ');
disp(' |                                       | ');
disp(' ----------------------------------------- ');

disp(' (1)  1MHz Small Payload 0.5 RAOs');
disp(' (2)  1MHz Small Payload 1 RAOs');
disp(' (3)  1MHz Large Payload 0.5 RAOs');
disp(' (4)  1MHz Large Payload 1 RAOs');

disp(' (5)  5MHz Small Payload 2 RAOs');
disp(' (6)  5MHz Small Payload 10 RAOs');
disp(' (7) 5MHz Large Payload 2 RAOs');
disp(' (8) 5MHz Large Payload 10 RAOs');
disp(' ');

scenarioSelected                = input(' Scenario Selected: ');
Parameters                      = selectScenario(scenarioSelected);
REPS                            = input(' Repetitions: ');
Ns_vector                       = input(' Ns_vector (example 100:100:2400): ');
Parameters.traffic.arrivalRate  = input(' Arrival Rate (1/6 or 1/60): ');
Parameters.options.sequence     = input(' Sequence (full | short): ','s');
Parameters.rach.M               = input(' Number of RACH transmissions (M = 10): ');
if (isempty(Ns_vector))
     Ns_vector = 100:100:2400;
end

Parameters.usedPRBs_UL = zeros(1,Parameters.system.simulationLen);
Parameters.usedPRBs_DL = zeros(1,Parameters.system.simulationLen);
Parameters.usedPHYs = -1*ones(1,Parameters.system.simulationLen);

%% Main Function
tic

% Initialize
outage        = zeros(1, numel(Ns_vector));
failures      = zeros(1, numel(Ns_vector));
probCollision = zeros(1, numel(Ns_vector));

parfor i=1:length(Ns_vector)
    for j=1:REPS
        USERS = worker(Ns_vector(i), Parameters);
        outage(i) = calculateOutage(USERS, Parameters) + outage(i);
        failures(i) = calculateFailure(USERS, Parameters) + failures(i); % We look at reportDataFailures only, in case tx didn't finish
        probCollision(i) = calculateProbCollision(USERS, Parameters) + probCollision(i);
    end
end

outage   = outage/REPS *100;
failures = failures /REPS * 100;
probCollision = probCollision / REPS;
toc


%% Save Results
name = [Parameters.options.sequence, 'Scenario_' num2str(scenarioSelected) '_Sequence_' Parameters.options.sequence '_arrivalRate_' num2str(Parameters.traffic.arrivalRate) 's'];
datetime=datestr(now);
datetime=strrep(datetime,':','_');% Replace colon with underscore
datetime=strrep(datetime,'-','_');% Replace minus sign with underscore
datetime=strrep(datetime,' ','_');% Replace space with underscore
save(['Results/',name,'_',datetime]);
