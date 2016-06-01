function USERS = happyEndingReport(UID, USERS, RAO, sfn, Parameters)
% Just store the success/successes and move to the next arrival

for i=1:numel(UID)
    ID = UID(i);
    index = USERS(ID).reportIndex;
    numBundled  = USERS(ID).bundleIndex(index);
    USERS(ID).reportSuccesses(index:index+numBundled) = sfn;
%     USERS(ID).reportQueued(index:index+numBundled) = USERS(ID).reportArrivals(index:index+numBundled);
    
    if(sfn<USERS(ID).reportArrivals(index)) % debugging
        disp('happyending mysterious bug')
        disp(['ID: ',num2str(ID),' report: ',num2str(index),' bundle:',num2str(numBundled),' arrival:',num2str(USERS(ID).reportArrivals(index)),' success:',num2str(sfn)]);
    end
    
    USERS(ID).granted = sfn;
    USERS = nextReport(ID, USERS, RAO, sfn, Parameters);
end

end
