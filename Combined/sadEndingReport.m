function USERS = sadEndingReport(UIDs, UID, type, USERS, RAOs, sfn, Parameters)
% Just store failure and select the next arrival

for i=1:numel(UID)
    index = USERS(UID(i)).reportIndex;
    numBundled  = USERS(UID).bundleIndex(index);
    USERS(UID(i)).reportFailures(index:index+numBundled) = sfn;
%     USERS(ID).reportQueued(index:index+numBundled) = USERS(ID).reportArrivals(index:index+numBundled);
    if(strcmp(type,'RRC_Request') && numel(UIDs)>1) % RACH Collision
        USERS(UID(i)).rachCollisions(index:index+numBundled) = sfn;
    end

    USERS = nextReport(UID(i), USERS, RAOs, sfn, Parameters);
end

end