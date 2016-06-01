function USERS = storeData(IDs,sfn, USERS)

for i=1:numel(IDs)
    ID = IDs(i);
    reportIndex = USERS(ID).reportIndex;
    if( ~USERS(ID).reportQueued(reportIndex) )
        USERS(ID).reportQueued(reportIndex) = sfn;
    end
    USERS(ID).nextRACH = 0;
    USERS(ID).nextTX = 0;
end

end