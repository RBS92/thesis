function [cumNeededRBs, fragmented, macOK] = processMAC( message, usedPRBs_DL, usedPRBs_UL, enb, ue, pdsch, pusch, modulation, availablePRBs, splitFactor, Parameters)

% Initialize
macOK      = 0;
fragmented = 0;
cumNeededRBs = 0;
%modulation = message.mac.modulation;
payload    = message.mac.payload;
where      = message.mac.where; % UL or DL  

switch (where)
    case 'DL'
        capacityPerRB = prbDLCapacity(enb, pdsch, modulation, Parameters.system.Rate); % Vector with bits per each RB in the BW. For example    ( 288, 288, 288, 288, 288, 288)
        usedPRBs      = usedPRBs_DL;                                                   % Vector with 1 when used and 0 if not used. For example: (  1,   1,   0,   0,   0,   0)
    case 'UL'
        capacityPerRB = prbULCapacity(ue,  pusch, modulation, Parameters.system.Rate);
        usedPRBs      = usedPRBs_UL;
end

remainingBits = sum(capacityPerRB' .* (1-usedPRBs));

if(remainingBits)
   
    %% Fragmentation
    % We split the resources evenly among all waiting UEs without exceed the
    % max PDCCHs messages, so that all the resources are used.
    % TODO: split resources better when splitFactor and PRBs are not even. 
    allocatedBits = min([remainingBits, ceil(availablePRBs/splitFactor)*capacityPerRB(1), Parameters.options.fragThreshold *capacityPerRB(1)]);
    if( payload && payload > allocatedBits)
        fragmented = allocatedBits;
        payload = allocatedBits;
    end    

    %% Allocation
    % We assume contiguous allocation. And we always start from the left
    % assigning the PRBs. With cumsum we known how many PRBs we need
    % including the ones already needed (it is a cumulative value!).

    cumNeededRBs = find(payload <= cumsum(capacityPerRB'.*(1-usedPRBs)),1,'first'); 
    if (~isempty(cumNeededRBs))
        macOK = 1;
    else
        cumNeededRBs = 0;
    end
end % if remaining bits
end

