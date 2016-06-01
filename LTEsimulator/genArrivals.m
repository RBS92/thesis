function [validatedArrivals, data] = genArrivals(pop,arrivalrate,datastart,datacutoff,alpha,Parameters)

%generate arrivals

arrivals = exprnd(1/arrivalrate/Parameters.system.tdma, pop, Parameters.maxReports);
arrivalsSFN = round(cumsum(arrivals, 2));
validatedArrivals = arrivalsSFN.* (arrivalsSFN<= Parameters.system.simulationLen);


% add data to the arrivals
data = gprnd(alpha,alpha*datastart,datastart,pop,Parameters.maxReports);
while(sum(data > datacutoff))
    data(data > datacutoff) = gprnd(alpha,alpha*datastart,datastart,size(data(data > datacutoff)));
end
data = floor(data);
end