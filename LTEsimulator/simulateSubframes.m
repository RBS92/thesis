function [USERS,UsedPRBs,dataPRBs, Parameters] = simulateSubframes(USERS, RAO, Parameters)
% Simulate every subframe during the simulation time.
enb   = Parameters.enb;
ue    = Parameters.ue;
pdsch = Parameters.pdsch;
pusch = Parameters.pusch;

% Initilize
messages = [];
dataPRBsBuf = 0;
dataPRBs = zeros(1,Parameters.system.simulationLen);
% MacFails = 0;
% PhyFails = 0;
% noErrors = 0;
targetID = 4;
% % % arrivalsBuf = [1000 1050 1100 1500];
% % % dataBuf = [200 200 200 200];
% % % Preambles = round(rand(round(1.1),Parameters.rach.M)*(Parameters.rach.PREAMBLES-1))+1;
% % % USERS(1).reportArrivals(1:numel(arrivalsBuf)) = arrivalsBuf;
% % % USERS(1).reportDatasize(1:numel(dataBuf)) = dataBuf;
% % % USERS(1).nextRACH = arrivalsBuf(1) + find( RAO(arrivalsBuf(1):arrivalsBuf(1)+20) > 0,1) - 1;
% % % USERS(1).PREAMBLES = Preambles(:);
% % % 
% % % arrivalsBuf = [1150 1200 1250 1300 1350 1400 1450];
% % % dataBuf = [20 20 20];
% % % Preambles = round(rand(round(1.1),Parameters.rach.M)*(Parameters.rach.PREAMBLES-1))+1;
% % % USERS(2).reportArrivals(1:numel(arrivalsBuf)) = arrivalsBuf;
% % % USERS(2).reportDatasize(1:numel(dataBuf)) = dataBuf;
% % % USERS(2).nextRACH = arrivalsBuf(1) + find( RAO(arrivalsBuf(1):arrivalsBuf(1)+20) > 0,1) - 1;
% % % USERS(2).PREAMBLES = Preambles(:);
% for sfn = 1:Parameters.system.simulationLen
sfn = 1;
while(sfn)
    % Initialize
    if(isempty(messages))
%         sfn = 1000;

        RRCexpiration = [USERS.RLCexpiration];
        RRCexpirationIDs = find(RRCexpiration~=0);
            
%         if(isempty(next))
% %             display('no more messages')
% 
%             if(~isempty(RRCexpirationIDs))
%                 for ID = RRCexpirationIDs
%                     if(USERS(ID).RLCexpiration<Parameters.system.simulationLen)
%     %                     display('expired')
%                         USERS(ID).RLC = 0;
%                         USERS(ID).RLCexpiration = 0;
%                         USERS(ID).nextTX = 0;
%                         
%                         USERS = reReport(ID, USERS, RAO, sfn, Parameters);
%                     end
%                 end
%             end
%             
%             break;
        next = [[USERS.nextRACH],[USERS.nextTX]];
%         size(next)
        next = next(next~=0);
%         another = 1;
        display(['no messages at: ',int2str(sfn),' jumped to: ',num2str(min(next))])
    	sfn = min(next);
        if(isempty(sfn))
            break;
        end
        
        if(~isempty(RRCexpirationIDs))
            for (ID = RRCexpirationIDs)
                if(USERS(ID).RLCexpiration<sfn)
%                     display('expired')
                    USERS(ID).RLC = 0;
                    USERS(ID).RLCexpiration = 0;
                    USERS(ID).RACHY = USERS(ID).nextRACH;
                    USERS = reReport(ID, USERS, RAO, sfn, Parameters);
                    USERS(ID).RACHT = USERS(ID).nextRACH;
                    USERS(ID).nextTX = 0;
                    USERS(ID).clear = sfn;
                end
            end
        end
        
    else
        sfn = sfn+1;
%         another=0;
    end
    
    if(sfn >= Parameters.system.simulationLen)
       break; 
    end
%     display(['SFN: ',num2str(sfn)])
    
    sentMsgIDs = [];
    enb.NSubframe = mod(sfn, 9);
    ue.NSubframe  = enb.NSubframe;
    ue.RAO        = 0;

    %% Schedule Requests (SR)

        % TODO (Other version of packet bundling?....)
    
    %% RRC connections update
    unConnectedIDs = find([USERS.RLC]==0);
    connectedIDs = find([USERS.RLC]~=0);
    for k = connectedIDs
        USERS(k).con = USERS(k).con +1;
    end
    
    %% Add transmissions
    RRCactiveIDs = [USERS(connectedIDs).nextTX]==sfn;
    RRCactiveIDs = connectedIDs(RRCactiveIDs);
    if(~isempty(RRCactiveIDs))
        for k = 1:numel(RRCactiveIDs)
            pos = USERS(RRCactiveIDs(k)).pos;
            currentMessage.mac  = struct('type', 'Security_Complete'); %schedule data tx
            currentMessage.dataSize = USERS(RRCactiveIDs(k)).reportDatasize(USERS(RRCactiveIDs(k)).reportIndex);
            messages            = addMessage(RRCactiveIDs(k), currentMessage, messages, sfn, pos, Parameters);
            messages(end).stats.RRC = 1;
            %RRC connection not inactive
            USERS(RRCactiveIDs(k)).RLCexpiration = sfn + Parameters.timers.RLCexpire;
            USERS = storeData(activeIDs, sfn, USERS); % For debugging
            Parameters.stats.noRRC = Parameters.stats.noRRC + 1;
        end
    end
    
    %% Random Access Channel (RACH)
    if (RAO(sfn) && ~isempty(unConnectedIDs))
        activeIDs = [USERS(unConnectedIDs).nextRACH]==sfn;
        activeIDs = unConnectedIDs(activeIDs);
        if (~isempty(activeIDs))
%             display(['IDs: ',num2str(activeIDs),' I: ',num2str([USERS(activeIDs).reportIndex])]);
            pos = USERS(activeIDs).pos;
            activePreambles     = [USERS(activeIDs).nextPreamble];
            currentMessage.mac  = struct('type', 'RACH', 'preambles', activePreambles);
            
            databuf = [];
            for m=1:length(activeIDs)
                databuf = [databuf USERS(activeIDs(m)).reportDatasize(USERS(activeIDs(m)).reportIndex)];    
            end
            currentMessage.dataSize = databuf;
            messages            = addMessage(activeIDs, currentMessage, messages, sfn, pos, Parameters); % Add RAR Message
            USERS = storeData(activeIDs, sfn, USERS); % For debugging
            Parameters.stats.noRA = Parameters.stats.noRA + numel(activeIDs);
        end
        ue.RAO = 6; % Less RBs in PUSCH
    end % if RAO

    %% Populate PDSCH and PUSCH
    if (~isempty(messages))
        [USERS,sentMsgIDs, messages, Parameters, dataPRBsBuf] = sendMessages(USERS, sentMsgIDs, messages, enb, ue, pdsch, pusch, sfn, Parameters);
    end
    dataPRBs(sfn) = dataPRBsBuf;
    
    %% Schedule Next Messages
    if (~isempty(sentMsgIDs))
        [messages, USERS] = addNextInSequence(sentMsgIDs, messages, USERS, sfn, RAO, Parameters);
%         debuggingQueue(messages,sentMsgIDs, targetID, USERS, sfn, Parameters);
    end

    %% Release expired RRC connections
    RRCexpirationIDs = find([USERS.RLCexpiration]~=0);
    if (~isempty(RRCexpirationIDs))
        for k = 1:length(RRCexpirationIDs)
            ID = RRCexpirationIDs(k);
            if(USERS(RRCexpirationIDs(k)).RLCexpiration<sfn)
%                 display('expired')
                USERS(ID).RLC = 0;
                USERS(ID).RLCexpiration = 0;
                USERS(ID).RACHY2 = USERS(ID).nextRACH;
                USERS = reReport(ID, USERS, RAO, sfn, Parameters);
                USERS(ID).RACHT2 = USERS(ID).nextRACH;
                USERS(ID).nextTX = 0;
                USERS(ID).clear = sfn;
%                 display(['expired ID: ',num2str(ID),' index: ',num2str(USERS(ID).reportIndex)])
%                 USERS(ID).nextRACH = arrivalsBuf(reportIndex) + find( RAO(arrivalsBuf(reportIndex):arrivalsBuf(reportIndex)+20) > 0,1) - 1;
            end
        end
    end

    %% Update Queues
    if (~isempty(messages))
        [messages, USERS, Parameters] = deleteMessages(sentMsgIDs, messages, USERS, sfn, RAO, Parameters);
    end
end

%% Take care of unfinished messages
USERS = unfinishWork(messages, USERS, Parameters);

UsedPRBs = [Parameters.stats.usedPRBs_UL;Parameters.stats.usedPRBs_DL];

end % function