function failuresPer = calculateFailure(USERS, Parameters)

arrivals = [USERS.reportArrivals]>0; 
failures= [USERS.reportFailures]>0;
failuresPer = sum(failures)/sum(arrivals);

end