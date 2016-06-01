function USERS = unfinishWork(messages, USERS, Parameters)
% All reports left should be deleted as the simulation is ending....

totalReportsDeleted = 0;

for i=1:numel(messages)
    UID = messages(i).mac.UID;
    for j=1:numel(UID)
        ID = UID(j);
        reportIndex = USERS(ID).reportIndex;
        reports = USERS(ID).reportArrivals;
        queued = USERS(ID).reportQueued;
        validReports = ones(1,Parameters.maxReports);
        validReports(reportIndex:end) = 0;
%         nValidRep = size(validReports)
%         nRep = size(reports)
        finalReports = reports .* validReports;
        queued       = queued .*validReports;
        USERS(ID).reportArrivals = finalReports;
        USERS(ID).reportQueued = queued;   
        totalReportsDeleted = sum(reports>0) - sum(finalReports>0) + totalReportsDeleted;
    end
end

IDs = ceil(find(([USERS.reportArrivals]>0).*([USERS.reportSuccesses]==0).*([USERS.reportFailures]==0))/Parameters.maxReports);
for ID = IDs
    remove = find(USERS(ID).reportArrivals>0,1,'last');
	USERS(ID).reportArrivals(remove) = 0;

end
totalReportsDeleted = totalReportsDeleted + numel(IDs);
disp(['Simulation time ending... Deleting ', num2str(totalReportsDeleted), ' reports.']);