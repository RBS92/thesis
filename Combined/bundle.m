function [messages,USERS,IDs] =bundle(messages,USERS,IDs,bundlingIDs,RAOs, sfn,Parameters)

index = [];
UIDs = [];
for(i = 1:length(IDs))
    if(any(bundlingIDs == IDs(i)))
        index = [i, index];
    end
    for(k = 1:numel(messages))
        UIDs = [UIDs,messages(k).mac.UID];
    end
    msg = find(UIDs == IDs(i),1);
    if(~isempty(msg))
        msg
        messages(msg).mac.payload = messages(msg).mac.payload + Parameters.traffic.dataSize * 8;
        messages(msg).mac.bundled = messages(msg).mac.bundled +1;
        if(messages(msg).mac.bundled == 1)
            messages(msg).mac.bundleIndex = USERS(IDs(i)).reportIndex;
        end
        USERS = nextReport(IDs(i), USERS, RAOs, sfn, Parameters);
    end
end
IDs(index) = [];