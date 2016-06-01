function messages = addMessageShort(UIDs, currentMessage, messages, sfn, pos, Parameters)
% Create the nextMessage content and append to the list of messages.
preambles      = 0; % Has to do with preambles in the RAR message, but it doesn't matter here.
rnti           = 0; % Zero by default.... Yet to be implemented.
nextModulation = modulation.QPSK; % Signalling uses QPSK.
timers         = Parameters.timers;

switch (currentMessage.mac.type)
    case 'RACH'
        nextType        = 'RAR';
        nextPayload     = numel(unique(currentMessage.mac.preambles))*8*8; % Payload in bits
        nextPdcchFormat = 1;
        preambles       = currentMessage.mac.preambles;
        nextWhere       = 'DL';
        timer           = timers.rar;

    case 'RAR'
        nextType        = 'RRC_Request';
        nextPdcchFormat = -1; % Not necessary. Already included in the RAR sent.
        nextPayload     = 7 * 8;
        nextWhere       = 'UL';
        timer           = timers.rrc_request;
        preambles       = currentMessage.mac.preambles;

    case 'RRC_Request'
        nextType = 'RRC_Connect';
        nextPdcchFormat = 1;
        nextPayload     = 38 * 8;
        nextWhere       = 'DL';
        timer           = timers.rrc_connect;    
    
    case 'RRC_Connect'        
        nextType = 'Data';
        nextPdcchFormat = 1;
        nextPayload     = currentMessage.dataSize * 8;
        nextModulation  = Parameters.system.dataModulation;
        nextWhere       = 'UL';
        timer           = timers.data;
        %warning('Change data payload to work automatically');
       
    case 'DATA'
        warning('Data message should not being processed here');
        
    otherwise
        warning('Unknown Message Type');
        nextType='Unkwown';
        nextPdcchFormat = -1;
end % switch

% Create and append the new message
message = createMessage(UIDs, sfn, nextPayload, nextType, nextWhere, nextModulation, preambles, timer, rnti, nextPdcchFormat, pos,currentMessage.dataSize);
if(~isempty(messages))
    messages(end+1) = message;
else
    messages = message;
end

