function [USERS,sentMsgIDs, messages, Parameters, dataPRBs] = sendMessages(USERS,sentMsgIDs, messages, enb, ue, pdsch, pusch, sfn, Parameters)
% Populates the PDSCH and PUSCH of a given subframe based on the pending
% mac messages. The PDCCH is also populated so PDSCH/PUSCH can be actually
% used. Note that PUCCH is not considered sor far....

% Initialize
dataPRBs = 0;
usedPRBs_DL   = zeros(1,enb.NDLRB);
usedPRBs_UL   = zeros(1,ue.NULRB - ue.RAO);
availablePRBs = ue.NULRB - ue.RAO;
pdcchInfo     = Parameters.pdcchInfo;
usedPdcchBits = zeros(1,pdcchInfo.MTot);
remainingCCEs = pdcchInfo.NCCE.*uint64(Parameters.options.phyCapacity==0) + Parameters.options.phyCapacity *2; % phyCapacity overwrites real value if active (>0) (x2 to convert to CCEs)
totalCCEs     = remainingCCEs;

% Process all messages
splitFactorUL = 1;

for i=1:numel(messages)
    if ( sfn > messages(i).sfn + Parameters.system.processingTime )       
        %% Bundle user data
        UID = messages(i).mac.UID;  
        if(strcmp(messages(i).mac.type,'Data') && ~messages(i).mac.bundled && numel(UID)==1 ) % Patch: Avoid counting reports again if message is fragmented.      
            waitingReports = (USERS(UID).reportArrivals < sfn).* USERS(UID).reportArrivals; 
            reports = sum(waitingReports>0);
            n = max(min(reports-USERS(UID).reportIndex, Parameters.system.B-1),0);  % Do not bundle the same report twice
%             if(n)
%                 disp([' SFN: ', num2str(sfn), ' -> ', 'Bundling ',num2str(n), ' reports. Up to ' num2str(reports-USERS(UID).reportIndex), ' available.']);
%             end
            messages(i).mac.payload = sum(USERS(UID).reportDatasize(USERS(UID).reportIndex:USERS(UID).reportIndex+n)*8);
            messages(i).mac.bundled = 1;
            if(n)
                USERS(UID).reportQueued((USERS(UID).reportIndex+1):(USERS(UID).reportIndex+n)) = sfn;
            end            
            USERS(UID).bundleIndex(USERS(UID).reportIndex) = n;
%         elseif(strcmp(messages(i).mac.type,'Data')&& numel(UID)==1 )
%             messages(i).mac.payload = USERS(UID).reportDatasize(USERS(UID).reportIndex)*8;
        end
%         messages(i).mac.payload
        %% PHY Layer
        [pdcchPositions, neededCCEs, modulationSelected, peTX, phyOK] = processPHY( messages(i), enb, remainingCCEs, usedPdcchBits, Parameters);
        
        %% MAC Layer
        [cumNeededRBs, fragmented, macOK] = processMAC(messages(i), usedPRBs_DL, usedPRBs_UL, enb, ue, pdsch, pusch, modulationSelected, availablePRBs, splitFactorUL, Parameters);        
        
        %% Ideal Performance (if activated)
        macOK = or(macOK, Parameters.options.runIdealMAC);
        phyOK = or(phyOK, Parameters.options.runIdealPHY);
        
        messages(i).stats.notenoughCCEs = messages(i).stats.notenoughCCEs + (phyOK<1);
        messages(i).stats.notenoughRBs = messages(i).stats.notenoughRBs + (macOK<1);
      
        %% Send Message?
        if( macOK && phyOK) 
            sentMsgIDs = [sentMsgIDs, i];
            
            % Update Information regarding message
            messages(i).mac.fragmented = fragmented;
            messages(i).mac.modulation = modulationSelected;
            messages(i).phy.peTX       = peTX;
            remainingCCEs = remainingCCEs - neededCCEs;
            
            % Update PRBs
            if (strcmp(messages(i).mac.where,'DL'))
                for j = UID
                    USERS(j).rx = USERS(j).rx +1;
                end                
                usedPRBs_DL(1:cumNeededRBs) = 1; % Some positions will be overwritten, but cumNeededRS include the already existing... thus it is ok. 
            else
                for j = UID
                    USERS(j).tx = USERS(j).tx +1;
                end                
                usedPRBs_UL(1:cumNeededRBs) = 1;
                if(strcmp(messages(i).mac.type,'Data') && ~isempty(cumNeededRBs))
                    dataPRBs = dataPRBs + cumNeededRBs;
                end
            end
            usedPdcchBits(pdcchPositions) = 1;
        end % if

        %% Minimum Space Required Avaiable?    
        if( all(usedPRBs_DL) && all(usedPRBs_UL) ) % No free PRBs

            neededCCEs = 2;
            if(remainingCCEs<neededCCEs)
                noCCE = 1;
            else
                noCCE = 0;
            end
            
            for j = i+1:numel(messages)
                messages(j).stats.notenoughCCEs = messages(i).stats.notenoughCCEs + noCCE;
                messages(j).stats.notenoughRBs = messages(i).stats.notenoughRBs + 1;
            end
            
            break; % No more messages can be sent leaving....
        end
    else
        break;
    end % if processing time
end %for

% Debugging
Parameters.stats.usedPRBs_UL(sfn) = sum(usedPRBs_UL);
Parameters.stats.usedPRBs_DL(sfn) = sum(usedPRBs_DL);
Parameters.stats.usedPHYs(sfn) = (totalCCEs - remainingCCEs)/2;
