unfinished = 0;

reports = [USERS.reportArrivals];
%reports(reports==0) = [];

successes = [USERS.reportSuccesses];
%successes(successes==0) = [];

failures = [USERS.reportFailures];
%failures(failures==0) = [];

queued = [USERS.reportQueued];
%queued(queued == 0) = [];

sumreports = sum([USERS.reportArrivals]>0)
sumsuccesses = sum([USERS.reportSuccesses]>0)
sumfailures  = sum([USERS.reportFailures]>0)
sumqueued = sum([USERS.reportQueued]>0)


disp(['Total Reports: ', num2str(sumreports), '. Proccessed reports: ', num2str(unfinished+sumsuccesses+sumfailures)]);
disp(['Queued Reports: ', num2str(sumqueued)]);


% %% Display data
% figure(2); hold on; grid on;
% 
% for i=1:numel(reports)
%     subframe = reports(i);
%     if (subframe)
%         scatter(subframe,0,'.k');
%         if (successes(i))
%             scatter(subframe,0,'og');
%         end
%         if (failures(i))
%             scatter(subframe,0,'xr');
%         end
%     end
% end
% 
% 
% 
% % stem(reports, ones(1,length(reports)),'-k'); hold on; grid on;
% % stem(successes,ones(1,length(successes)), '-*g');
% % stem(failures, ones(1,length(failures)),'-xr');
% % 
% 
% figure(3);
% stem(reports, ones(1,length(reports)),'-k'); hold on; grid on;
% stem(queued, ones(1,length(queued)),'-sm');

%% Others

condition = ( [USERS.reportFailures]==0) .* ([USERS.reportSuccesses]==0) .* ([USERS.reportArrivals]>0) .*([USERS.reportArrivals]< (Parameters.system.simulationLen - 200));
roguesPosition = find( condition)

IDs = unique(ceil(roguesPosition/Parameters.maxReports));
for i=1:length(IDs)
    ID = IDs(i);
    if (USERS(ID).nextRACH < Parameters.system.simulationLen)
        USERS(IDs(i))
    end
end

%% Display Data
% figure(2);
% scatter(reports(roguesPosition),zeros(1,length(roguesPosition)),'sm');