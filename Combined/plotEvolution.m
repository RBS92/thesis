figure(1);
clf;
hold on; grid on;
figure(2);
clf;
hold on; grid on;

served = 0;
totalArrivals = 0;
unproccessed = 0;
newArrivals = zeros(1, subframes);
served 
for sfn=1:10000
    
    newArrivals(sfn) = numel(find([USERS.reportArrivals]==sfn));
    served(sfn) = numel(find([USERS.reportSuccesses]==sfn));
    totalArrivals = totalArrivals + newArrivals(sfn);
    unproccessed = unproccessed - served(sfn) + newArrivals(sfn);
    
    plotTot(sfn) = totalArrivals;
    plotUn(sfn) = unproccessed;
   
end
    figure(1);
    plot(1:10000, plotTot, '-sk'); hold on;
    plot(1:10000, plotUn, '-or'); hold on;
    
    figure(2);
    plot(1:10000, newArrivals, '-xm'); hold on;
    plot(1:10000, served, '-^g'); hold on;
    
    figure(3);
    stem(1:10000, newArrivals-served); hold on; 