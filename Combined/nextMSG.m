function [nextMessage, pdcchFormat] = nextMSG(currentMessageType)
% Yeah, I know... WTF?! Enumerate option in MATLAB is not better so....
% deal with it!
switch (currentMessageType)
    case 'RAR'
        nextMessage = 'RRC_Request';
        pdcchFormat = -1; % Not necessary. Already included in the RAR sent.
    
    case 'RRC_Request'
        nextMessage = 'RRC_Connect';
        pdcchFormat = 1;
        
    case 'RRC_Connect'
        nextMessage = 'RRC_Complete';
        pdcchFormat = 1;

    case 'RRC_Complete'
        nextMessage = 'RRC_ReconfigurationDL';
        pdcchFormat = 1;

    case 'RRC_ReconfigurationDL'
        nextMessage = 'RRC_ReconfigurationUL';
        pdcchFormat = 1;

    case 'RRC_ReconfigurationUL'
        nextMessage = 'RRC_Release';
        pdcchFormat = 1;

    case 'RRC_Release'
        nextMessage = 'Security_Command';
        pdcchFormat = 1;

    case 'Security_Command'
        nextMessage = 'Security_Complete';
        pdcchFormat = 1;

    case 'Security_Complete'
        nextMessage = 'DATA';
        pdcchFormat = 1;

    otherwise
        disp('Unknown Message Type');
        nextMessage='Unkwown';
        pdcchFormat = -1;
end % switch
end % function