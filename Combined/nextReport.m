function USERS = nextReport(ID, USERS, RAOs, sfn, Parameters)

% Store results last report
reportIndex = USERS(ID).reportIndex;
USERS(ID).granted = sfn;

% Generate RACH Preambles and reinitialize RACH logs
numBundled  = USERS(ID).bundleIndex(reportIndex);
% USERS(ID).reportIndex = reportIndex + numBundled; 
reportIndex = reportIndex + numBundled + 1;

if ( (reportIndex <= Parameters.maxReports) && (USERS(ID).reportArrivals(reportIndex) > 0) ) % More reports
     
    USERS(ID).PREAMBLES  = round(rand(1,Parameters.rach.M)*(Parameters.rach.PREAMBLES-1))+1;
    USERS(ID).reportIndex = reportIndex; 

    nextRACH   = USERS(ID).reportArrivals(reportIndex); 
    %msgType    = USERS(ID).msgType(reportIndex);
    if (nextRACH > sfn)
        subframe = nextRACH;
    else
        subframe = sfn + 1;
    end
    
%     USERS(ID).nextTX = subframe;
    
    % We now know the subframe arrival will be activated
    shift = find( RAOs(subframe:subframe+20) > 0,1) - 1; % Select closest RAO (At lest one every 20 subframes)!

    if (~isempty(shift))
        subframe = subframe + shift;

        % Update RACH Info
        USERS(ID).RACHS(1) = subframe;
        USERS(ID).nextRACH = subframe;
        USERS(ID).nextTX = subframe-shift;
        USERS(ID).TXS(1) = subframe-shift;
        USERS(ID).nextPreamble = USERS(ID).PREAMBLES(1);
        USERS(ID).granted = 0;

    else
        disp(' Warning: No more RAOs killing report/s...');
        USERS(ID).reportFailures(reportIndex) = sfn;

        % Update RACH Info
        USERS(ID).RACHS(1) = 0;
        USERS(ID).nextRACH = 0;
        USERS(ID).nextTX = subframe;
        USERS(ID).TXS(1) = subframe;
%         ID
        USERS(ID).PREAMBLES = 0;
        USERS(ID).nextPreamble = 0;
        USERS(ID).granted = 0;
%         USERS = nextReport(ID, USERS, RAOs, sfn, Parameters);
    end %else
else
%     disp('nextReport')
    USERS(ID).nextRACH = 0;
    USERS(ID).nextTX = 0;
end
end