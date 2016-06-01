function messages = addMessageFull(UIDs, currentMessage, messages, sfn, pos, Parameters, data)

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
        nextType = 'RRC_Complete';
        nextPdcchFormat = 1;
        nextPayload     = 20 * 8;
        nextWhere       = 'UL';
        timer           = timers.rrc_complete;

    case 'RRC_Complete'
        nextType = 'RRC_ReconfigurationDL';
        nextPdcchFormat = 1;
        nextPayload     = 118 * 8;
        nextWhere       = 'DL';
        timer           = timers.rrc_reconfigurationdl;

    case 'RRC_ReconfigurationDL'
        nextType = 'RRC_ReconfigurationUL';
        nextPdcchFormat = 1;
        nextPayload     = 10 * 8;
        nextWhere       = 'UL';
        timer           = timers.rrc_reconfigurationul;

    case 'RRC_ReconfigurationUL'
        nextType = 'Security_Command';
        nextPdcchFormat = 1;
        nextPayload     = 11 * 8;
        nextWhere       = 'DL';
        timer           = timers.security_command;


    case 'Security_Command'
        nextType = 'Security_Complete';
        nextPdcchFormat = 1;
        nextPayload     = 13 * 8;
        nextWhere       = 'UL';
        timer           = timers.security_complete;

    case 'Security_Complete'
        nextType = 'Data';
        nextPdcchFormat = 1;
        nextPayload     = currentMessage.dataSize * 8;
        nextModulation  = Parameters.system.dataModulation;
        nextWhere       = 'UL';
        timer           = timers.data;
        
    case 'DATA'
        error('Data message should not be processed in addMessage.m');
        
    otherwise
        error('Unknown Message Type in addMessage.m');
    
end % switch

% Create and append the new message
message = createMessage(UIDs, sfn, nextPayload, nextType, nextWhere, nextModulation, preambles, timer, rnti, nextPdcchFormat, pos,currentMessage.dataSize);
if(~isempty(messages))
    messages(end+1) = message;
else
    messages = message;
end
