function [USERS,activeAgg] = generateTraffic(USERS, Nd, Parameters)
% %% Traffic
% % tic
% Traffic = struct(...
% 'MARexception', [ ... % This one is ignored when generating poisson!
% 1   20 ...
%     ], ...
% 'MARperiodic', [ ...
% 1   40  20  200     2.5     1/(60*60*24); ...
% 2   40  20  200     2.5     1/(60*60*2); ...
% 3   15  20  200     2.5     1/(60*60); ...
% 4   5   20  200     2.5     1/(60*30); ...
%     ], ...
% 'netCmd', [ ...
% 1   40  20  20     0     1/(60*60*24);...
% 2   40  20  20     0     1/(60*60*2); ...
% 3   15  20  20     0     1/(60*60); ...
% 4   5   20  20     0     1/(60*30); ...
%     ], ...
% 'softUpdate', [ ...
% 1   100     200     2000    1.5     1/(60*60*24*180) ...
%     ] ...
% );
Traffic = Parameters.traffic.Traffic;

%% function
numberDevices = Nd;
% numberAggregators = Ns;
%%
validatedArrivals = zeros(numberDevices,Parameters.maxReports);
validData = zeros(numberDevices,Parameters.maxReports);
idArrivals = zeros(numberDevices,Parameters.maxReports);

%% Beta Arrivals
% generates Beta-distributed arrivals. We convert to SFN, adds to the
switch(Parameters.traffic.deviceModel)
    case 'PPP'
        posDevices = SpatialModel_PPP(Parameters.traffic.cellRadius,numberDevices);
    case 'PCP'
        [posDevices, posClusters] = SpatialModel_PCP(Parameters.traffic.cellRadius,numberDevices,Parameters.traffic.clusterRadius,numberAggregators);
end

if(Parameters.traffic.exception)
    trafficTypes = fieldnames(Traffic);
    first = getfield(Traffic,trafficTypes{1});
    
    Parameters.traffic.alarmWaveSpeed = Parameters.traffic.cellRadius*3/2/Parameters.traffic.period;
    
    distancesToAlarmTrigger = sqrt((Parameters.traffic.eventCentre(1)-posDevices(:,1)).^2+(Parameters.traffic.eventCentre(2)-posDevices(:,2)).^2);
    alarms = [ceil(0+distancesToAlarmTrigger'/Parameters.traffic.alarmWaveSpeed/Parameters.system.tdma)];
    alarms(rand(1,numberDevices)>=first(1,3)) = 0;
    validatedArrivals(:,1) = alarms';
    idArrivals(:,1) = repmat(1,size(alarms))';
    validData(:,1) = repmat(first(2),size(alarms))';
end

%% Poisson Arrivals
% Poisson inter-arrival times follows exponential. We converted to
% subframe number (SFN) and then elimiate those outside simulation time
% (mark as 0).

if(Parameters.traffic.poisson)
    trafficTypes = fieldnames(Traffic);
    nTrafficTypes = numel(fieldnames(Traffic));
    first = getfield(Traffic,trafficTypes{1}); % alarms
    [count, ~] = size(first);
    for i = 2:nTrafficTypes
        this = getfield(Traffic,trafficTypes{i});
        
        [nMsgs, ~] = size(this);
        cumPop = 0;
        for j=1:nMsgs
            id = count+j;
            pop = round(numberDevices*this(j,2)/100);
            arrivalrate = this(j,6);
            datastart = this(j,3);
            datacutoff = this(j,4);
            alpha = this(j,5);
            [arrivals, data] = genArrivals(pop,arrivalrate,datastart,datacutoff,alpha,Parameters);
            
%             [y,x]=hist(arrivals(arrivals~=0),100);
%             bar(x,y)
%             figure
%             msgId = repmat(id,size(data));
            
%             size(validatedArrivals)
%             size(validatedArrivals(cumPop+1:cumPop+pop,:))
            [Row, Col] = find(arrivals~=0);
            if(~isempty(Row))
%                 size(arrivals(lastRow, lastCol))
                for k =1:length(Row)
                    freeCol = find(validatedArrivals(cumPop+Row(k),:)==0,1,'first');
                    validatedArrivals(cumPop+Row(k),freeCol) = arrivals(Row(k), Col(k));
                    validData(cumPop+Row(k),freeCol) = data(Row(k), Col(k)) + Parameters.traffic.headerSize;
                    idArrivals(cumPop+Row(k),freeCol) = id;
                end
                
%                 [firstRow, firstCol] = find(validatedArrivals(cumPop+1:cumPop+1+pop,:) == 0,pop, 'first');
%             cumPop+firstRow
%             firstCol
%             size(validatedArrivals(cumPop+firstRow:cumPop+pop,firstCol:end))
%             size(arrivals(lastRow, 1:lastCol))
%                 validatedArrivals(cumPop+firstRow,firstCol:end) = arrivals(lastRow, 1:lastCol);
%             for k = cumPop+1:cumPop+1+pop
%             	firstCol = find(validatedArrivals(k,:)== 0,'first');
%                 lastCol = find(arrivals(k-cumPop,:) == 0,'first');
%                 validatedArrivals(k,firstCol
%             end
%                 validData(cumPop+firstRow,firstCol:end) = data(lastRow, 1:lastCol);
%                 idArrivals(cumPop+firstRow,firstCol:end) = msgId(lastRow, 1:lastCol);
            end
%             [y,x]=hist(validatedArrivals(arrivals~=0),100);
%             bar(x,y)
%             figure
%             cumPop = pop + cumPop;
            
        end
        count = count + nMsgs;
    end
end


activeAgg = 0;

for i=1:numberDevices
    USERS(i).pos = posDevices(i,:); % store position

    arrivalsBuf = validatedArrivals(i,:);
%     typeOfArrivalBuf = idArrivals(i,:);
    dataBuf = validData(i,:);

%     dataBuf(arrivalsBuf==0) = [];
%     typeOfArrivalBuf(arrivalsBuf==0) = [];                % Clear unused arrival types
    arrivalsBuf(arrivalsBuf==0) = [];                     % Clear unused arrival times
    [arrivalsBuf,bufIndex] = sort(arrivalsBuf);
%     typeOfArrivalBuf = typeOfArrivalBuf(bufIndex);
    dataBuf = dataBuf(bufIndex);

    if(length(arrivalsBuf)>Parameters.maxReports)
        display('maxReports is too small1')
    end

    if (arrivalsBuf)
        USERS(i).reportArrivals(1:length(arrivalsBuf)) = arrivalsBuf;
%         USERS(i).reportArrivalTypes(1:length(arrivalsBuf)) = typeOfArrivalBuf;
        USERS(i).reportDatasize(1:length(arrivalsBuf)) = dataBuf;
%         USERS(i).PREAMBLES            = Preambles(i,:);

        % Setup for the Initial RACH
        USERS(i).nextTX = arrivalsBuf(1);
%         USERS(i).nextPreamble = Preambles(i,1);
    end
end
% Vizualize arrivals
% poissonArrival = arrivalsSFN.* (arrivalsSFN<= Parameters.system.simulationLen);
validatedArrivals(validatedArrivals==0)=[];

% figure; hold on;
% stem(poissonArrival,ones(1,length(poissonArrival)),'blue')
% stem(betaArrival,ones(1,length(betaArrival)),'red')
% xlabel('Subframe [1 ms]')
% ylabel('Payload size')
% title('Arrival payloads in time')
% legend('Poisson','Beta')

% figure; hold on;
% bins = 100;
% [yp,xp] = hist(validatedArrivals,bins);
% bar(xp,yp,'blue')
% xlabel('Subframe [1 ms]')
% ylabel('Histogram of the number of arrivals')
% title('Number of arrivals in time')
% legend('Unified','Beta','Poisson')
% toc
% pause
%% Vizualize positions
% figure; hold on;
% scatter(posDevices(:,1),posDevices(:,2),'blue')
% scatter(posAggregators(:,1),posAggregators(:,2),'black')
% scatter(0,0,'red')
% for k = 1:numberDevices
%     l = line([posDevices(k,1),posAggregators(nodeAssocWith(k),1)]',[posDevices(k,2),posAggregators(nodeAssocWith(k),2)]');
%     l.Color = 'green';
% end
% xlabel('x-coordinate [m]')
% ylabel('x-coordinate [m]')
% title('Cell layout and aggregator associations')
% legend('M2M devices','Aggregators','eNB')

%% CDF of aggregator to device distances
% figure; hold on;
% dist = sqrt(sum((posDevices-posAggregators(nodeAssocWith,:)).^2,2)); % distance from devices to aggregators
% [y,x] = hist(dist);
% bar(x,y)
% xlabel('Distance [m]')
% ylabel('Number of pairs')
% UnconnectedAggregators = numberAggregators - sum(length(unique(nodeAssocWith)))
end
