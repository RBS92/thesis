function [messages,  USERS, Parameters] = deleteMessages(sentMsgIDs, messages, USERS, sfn, RAO, Parameters)
% Delete messages already processed (msgIDs) and reschedule expired
% messages (Parameters.timers)

% 1) Deleted processed messages (if not fragmented)
removeMsgIDs = [];
for i =1:numel(sentMsgIDs)
    index = sentMsgIDs(i);
    if ( ~messages(index).mac.fragmented || messages(index).errorInTX )
        
%         timePassed = sfn - [messages(index).sfn];
%         expired    = timePassed > [messages(index).timer] + Parameters.system.processingTime;
%         if(~expired) % otherwise handled by removing expired messages
%             removeMsgIDs = [removeMsgIDs, sentMsgIDs(i)];
%         end
        Parameters = saveStats(Parameters,messages(index));
        removeMsgIDs = [removeMsgIDs, sentMsgIDs(i)];
        USERS = storeLastMessage(USERS, 'Deleted', messages(index));
%         display(['Deleted: ', num2str(messages(index).mac.UID)])
%         % RRC_Request Stats: Correct Messages vs. Collided Messages
%         req = strcmp(messages(index).mac.type,'RRC_Request');
%         if (req && numel(messages(index).mac.UID)==1)
%             Parameters.stats.correctMSG3 = Parameters.stats.correctMSG3 + 1;
%         elseif (req)
%             Parameters.stats.collidedMSG3 = Parameters.stats.collidedMSG3 + 1;
%         end
    end
end
messages(removeMsgIDs) = [];


% 2) Process remaining messages
if (~isempty(messages))

%     errors = [messages.errorInTX];
    timePassed = sfn - [messages.sfn];
    expired    = find((timePassed > [messages.timer] + Parameters.system.processingTime));
    stats = [messages.stats];
    RRCexpired = find(([stats.RRC] == 1).*(timePassed > [messages.timer] + Parameters.system.processingTime));
%     RAR = ([messages.mac.rarIndex]==1); %"quick fix" fragmented RARs which are being served do not expire
%     expired = expired.*RAR;
    
    Parameters.stats.expiredMSG = Parameters.stats.expiredMSG + numel(expired);
    Parameters.stats.RRCexpiredMSG = Parameters.stats.RRCexpiredMSG + numel(RRCexpired);
    
    Ids = [];
    for i=1:numel(expired)
        if(messages(expired(i)).mac.rarIndex==1) %quick fix to not delete fragmented RARs which are being handled
            Parameters = saveStats(Parameters,messages(i));
            msgID = expired(i);
            Ids = [Ids, msgID];
            currentMessage  = messages(msgID);
            [USERS, messages] = retransmitMessage(currentMessage.mac.UID, currentMessage, messages, RAO, sfn, USERS, Parameters);
        end
    end
    messages(Ids) = [];
end
