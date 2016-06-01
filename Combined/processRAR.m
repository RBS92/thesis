function [messages, USERS] = processRAR(ID, currentMessage, messages, USERS, sfn, RAO, Parameters)
activeUEs    = currentMessage.mac.UID;
datasizes = currentMessage.dataSize;
numActiveUEs = numel(activeUEs);
preambles    = currentMessage.mac.preambles;
rarIndex     = currentMessage.mac.rarIndex;
errorUIDs = [];
%% 1) Control Channel (if error RAR message will be not be received by a given UE)
% errorInTX = rand(1,numActiveUEs) < 1-(1-([currentMessage.phy.peTX])).^messages(ID).mac.payload;
errorInTX = zeros(1,numActiveUEs);
activePreambles = preambles.*(1-errorInTX); % 0 means not active

%% 2) If MAC PDU is fragmented we can only grant maxGrants per subframe!
if (currentMessage.mac.fragmented)
    grantLimit   = floor(currentMessage.mac.fragmented / (8*8));
else
    grantLimit   = Parameters.rach.PREAMBLES; % No limitation, idealy all preambles can be acknowledged.
end

%% 3) Now let's find the repeated preambles that are active.
% In C{i} we get the preambles activated. C{i}(1) indicate each preamble
% activated  and C{1}(2:end) positions where the same preamble appears.

C = arrayfun(@(z)[z find(activePreambles==z)],unique(activePreambles),'Un',0 );
for i=rarIndex:min(numel(C),grantLimit+rarIndex -1)
    preamble = C{i}(1);
    if (preamble) % preamble = 0 means no RAR received! so only we skip those
        positions = C{i}(2:end); % Positions where preamble appears
        if (numel(positions)>1)
            % Collided UEs
            failedUIDs = activeUEs(positions); % All these guys goes to the same MSG3, i.e., collision!
            currentMessage.mac.preambles = preambles(positions);
            currentMessage.datasize = datasizes(positions);
            messages(ID).stats.collission = messages(ID).stats.collission + numel(failedUIDs);
            messages   = addMessage(failedUIDs, currentMessage, messages, sfn, currentMessage.phy.pos, Parameters);
        else
            % Singletons
            singleUID = activeUEs(positions);
            messages(ID).stats.correct = messages(ID).stats.correct + numel(singleUID);
            currentMessage.mac.preambles = preambles(positions);
            currentMessage.datasize = datasizes(positions);
            messages   = addMessage(singleUID, currentMessage, messages, sfn, currentMessage.phy.pos, Parameters);
        end
    else
        errorUIDs = [errorUIDs,activeUEs(C{i}(2:end))];

    end % if preamble
end


if (i==numel(C)) % All granted
    messages(ID).mac.fragmented = 0;
end

% Store index
if (currentMessage.mac.fragmented)
%     disp(num2str(messages(ID).mac.UID))
    messages(ID).mac.rarIndex = i + 1;
    messages(ID).mac.payload  = messages(ID).mac.payload - grantLimit * 64;
end

%% 3) Restart RACH for those who have error decoding RAR
if(errorUIDs)
    messages(ID).stats.txErrors = messages(ID).stats.txErrors + numel(errorUIDs);
	USERS  = rescheduleRACH(errorUIDs, currentMessage, sfn, RAO, USERS, Parameters);

%     display(['flag: ',num2str(errorUIDs)])
%     UID = errorUIDs;
%     for i=1:numel(UID)
%         display(['flag: ',num2str(UID(i)),' RRC: ',num2str(USERS(UID(i)).RLC),' index: ',num2str(USERS(UID(i)).reportIndex)])
%     end
end
    



    