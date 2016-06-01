function [messages, USERS] = addNextInSequence(sentMsgIDs, messages, USERS, sfn, RAO, Parameters)
% Go to next step for the indicated msgIDs

for i=1:length(sentMsgIDs)
    ID             = sentMsgIDs(i);
    currentMessage = messages(ID);
    fragmented     = currentMessage.mac.fragmented;
    UID            = currentMessage.mac.UID;
    pos            = currentMessage.phy.pos;
    USERS          = storeLastMessage(USERS, 'NextSequence_', messages(ID));
    
    if(~fragmented)
        errorInTX = rand(1) < 1-(1-(currentMessage.phy.peTX))^currentMessage.mac.payload;
    else
        errorInTX = rand(1) < 1-(1-(currentMessage.phy.peTX))^fragmented;
    end
    
    errorInTX = and(errorInTX,~Parameters.options.runIdealLink);
    messages(ID).errorInTX = errorInTX;
%     noErrors = noErrors + errorInTX;
    
    switch (currentMessage.mac.type)
        
        case 'RAR' 
            [messages, USERS] = processRAR(ID, currentMessage, messages, USERS, sfn, RAO, Parameters);
                           
        case 'Data' 
            if(~errorInTX && ~fragmented)
                USERS = happyEndingReport(UID, USERS, RAO, sfn, Parameters);
                for k = 1:length(UID);
                    USERS(UID(k)).RLC = 1;
                	USERS(UID(k)).RLCexpiration = sfn + Parameters.timers.RLCexpire;
%                     display('RLCexpiration set')
                end
                
            elseif (~errorInTX && fragmented)
                messages(ID).mac.payload = messages(ID).mac.payload - fragmented;
                messages(ID).sfn         = sfn; % Update with last tx for timers.              
            
            else
                % Retransmission
                messages(ID).stats.txErrors = 1;
                [USERS, messages] = retransmitMessage(UID, currentMessage, messages, RAO, sfn, USERS, Parameters);
            end
            
        % Messages like RRC_Connect, RRC_Request, Secury_Command, etc...
        otherwise
        
             if(~errorInTX && numel(UID) == 1 && ~fragmented)
                 messages = addMessage(UID, currentMessage, messages, sfn, currentMessage.phy.pos, Parameters);
                 %RLC connection established
%                  for k = 1:length(UID);
%                     USERS(UID(k)).RLC = 1;
%                     USERS(UID(k)).RLCexpiration = sfn + Parameters.timers.RLCexpire;
%                  end
                 
             elseif (~errorInTX && fragmented)
                 messages(ID).mac.payload = messages(ID).mac.payload - fragmented;
                 messages(ID).sfn         = sfn; % Update with last tx for timers.              
%                  display(['flag: ',num2str(messages(ID).mac.UID)])
                 
             elseif(numel(UID) == 1)% error decoding made us loose the message.  
                 messages(ID).stats.txErrors = 1;
%                  display(['flag: ',num2str(messages(ID).mac.UID)])
                 [USERS, messages] = retransmitMessage(UID, currentMessage, messages, RAO, sfn, USERS, Parameters);
             else % collission
%                  messages(ID).stats.collission = numel(UID) + messages(ID).stats.collission;
%                  display(['flag: ',num2str(messages(ID).mac.UID)])
%                  UID = messages(ID).mac.UID;
%                  for i=1:numel(UID)
%                     display(['RLC: ',num2str(USERS(UID(i)).RLC),' index: ',num2str(USERS(UID(i)).reportIndex)])
%                  end
                 USERS = rescheduleRACH(UID, currentMessage, sfn, RAO, USERS, Parameters);
             end
    end % switch
end % for

