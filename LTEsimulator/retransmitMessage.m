function [USERS, messages] = retransmitMessage(UIDs, currentMessage, messages, RAO, sfn, USERS, Parameters)

numTX = currentMessage.mac.numTX;

% index = find(messages.mac.UID == currentMessage.mac.UID);
% messages(index) = [];

if (numTX < Parameters.system.L) % retransmit message
    currentMessage.sfn = currentMessage.sfn + currentMessage.timer;
    currentMessage.mac.numTX = numTX + 1;
    currentMessage.errorInTX = 0;
    
    messages(end+1) = currentMessage;
else % restart RACH
    USERS  = rescheduleRACH(UIDs, currentMessage, sfn, RAO, USERS, Parameters);
end

end