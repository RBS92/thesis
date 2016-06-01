function messages = addMessage(UIDs, currentMessage, messages, sfn, pos, Parameters)

switch(Parameters.options.sequence)
    case 'full'
        messages = addMessageFull(UIDs, currentMessage, messages, sfn, pos, Parameters);
    case 'short'
        messages = addMessageShort(UIDs, currentMessage, messages, sfn, pos, Parameters);     
end

end
