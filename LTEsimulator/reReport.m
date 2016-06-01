function USERS = reReport(ID, USERS, RAOs, sfn, Parameters)

% Store results last report
% reportIndex = USERS(ID).reportIndex;
USERS(ID).granted = sfn;
nextTX = USERS(ID).nextTX;
% Generate RACH Preambles and reinitialize RACH logs
% numBundled  = USERS(ID).bundleIndex(reportIndex);
% USERS(ID).reportIndex = reportIndex + numBundled; 
% reportIndex = reportIndex + numBundled + 1;

if (nextTX>=sfn) % More reports
     
    USERS(ID).PREAMBLES  = round(rand(1,Parameters.rach.M)*(Parameters.rach.PREAMBLES-1))+1;
%     USERS(ID).reportIndex = reportIndex; 

    nextRACH   = nextTX; 
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
        USERS(ID).nextTX = 0;%subframe-shift;
        USERS(ID).nextPreamble = USERS(ID).PREAMBLES(1);
        USERS(ID).granted = 0;

    else
        disp(' Warning: No more RAOs killing report/s...');
        USERS(ID).reportFailures(reportIndex) = sfn;

        % Update RACH Info
        USERS(ID).RACHS(1) = 0;
        USERS(ID).nextRACH = 0;
        USERS(ID).nextTX = 0;%subframe;
%         ID
        USERS(ID).PREAMBLES = 0;
        USERS(ID).nextPreamble = 0;
        USERS(ID).granted = 0;
%         USERS = nextReport(ID, USERS, RAOs, sfn, Parameters);
    end %else
    USERS(ID).reRACH = USERS(ID).nextRACH;
else
%     disp('nextReport')
    USERS(ID).nextRACH = 0;
    USERS(ID).nextTX = 0;
end
end