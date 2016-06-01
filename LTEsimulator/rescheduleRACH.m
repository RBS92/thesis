function USERS  = rescheduleRACH(failUIDs, currentMessage, sfn, RAO, USERS, Parameters)
% These unlucky fellows have collided in MSG3 or some message fail too many
% times. They have to restart the RACH if maximum TXs was not reached.

newSubframe   = (currentMessage.sfn + currentMessage.timer + 1) * ones(1,numel(failUIDs));
backoffValues = round(rand(1,size(failUIDs,2))*(Parameters.rach.backoff));

%% Edit USERS Matrix
for i=1:length(failUIDs)
    if (newSubframe(i) <= sfn)
        newSubframe(i) = sfn + backoffValues(i) + 1;
    else
        newSubframe(i) =  newSubframe(i) + backoffValues(i);
    end
    
    % Get info regarding this failure
    shift       = find( RAO(newSubframe(i):newSubframe(i)+20) > 0,1) - 1;   % Minimum one RAO per 20 subframes 
    UID         = failUIDs(i);
    reportIndex = USERS(UID).reportIndex;
    TXs         = USERS(UID).reportRachTXs(reportIndex);
    
    % Update what just happened
    USERS(UID).PREAMBLES(TXs) = USERS(UID).nextPreamble;
%     preRACH = USERS(UID).nextRACH; % failsafe (unknown reason for happyending mysterious bug)
    % Update with what is going to happen
    if ( (TXs  < Parameters.rach.M) && (~isempty(shift)) )  
%         display('a')
        USERS(UID).RLC = 0;
        USERS(UID).RLCexpiration = 0;
        USERS(UID).nextRACH = newSubframe(i)+shift;   
        USERS(UID).nextTX = 0;
        USERS(UID).nextPreamble = USERS(UID).PREAMBLES(TXs+1);
        USERS(UID).reportRachTXs(reportIndex) = TXs + 1;

        USERS(UID).reportTXs(reportIndex) = USERS(UID).reportTXs(reportIndex)+currentMessage.mac.numTX;
    else % Report is lost
%         display(['sad: ',num2str(UID)])
        USERS(UID).nextRACH =0;
        USERS(UID).RLC = 0;
        USERS(UID).RLCexpiration = 0;
        USERS(UID).reportFailures(reportIndex) = sfn;
        USERS = sadEndingReport(failUIDs, UID, currentMessage.mac.type, USERS, RAO, sfn, Parameters);
        USERS(UID).nextTX = 0;  
    end
    
%     if(preRACH>USERS(UID).nextRACH)
%         USERS(UID).nextRACH = preRACH;
%     end
    USERS(UID).reRACH = USERS(UID).nextRACH;
    USERS(UID).reTX = USERS(UID).nextTX;
end % for

    
