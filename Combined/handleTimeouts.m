function [messages, USERS] = handleTimeouts(messages, USERS, sfn)
messages
IDs = find([messages.timer]<= sfn); % IDs of messages which are timeout

display(['Timed out messages ',num2str(length(IDs))])

for j = 1:length(IDs)
    % Handle the timeouts
    switch(messages(IDs(j)).mac.type)
        case 'DATA'
            
        otherwise,
    end
end