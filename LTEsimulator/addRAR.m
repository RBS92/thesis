function messages = addRAR(activeIDs, activePreambles, sfn, messages)

% Create RAR Message
payload     = numel(activePreambles)*8*8; % Payload in bits
pdcchFormat = 1;
rnti        = 0;
message     = createMessage(activeIDs, sfn, modulation.QPSK, payload, 'RAR', 'DL', activePreambles, rnti, pdcchFormat);

% Add RAR Message
if (isempty(messages))
    messages = message;
else
    messages(end+1) = message;
end

end %function