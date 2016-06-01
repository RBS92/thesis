function USERS_LTE = nextstruct(USERS_LTE,USERS,nodeAssocWith,Preambles,RAO)

for i = 1:numel(USERS_LTE)
    
    linkedDevices = find(nodeAssocWith == i);

    typeOfArrivalBuf = [];
    arrivalsBuf = [];
%     distances = [];
    dataBuf = [];

    for j = linkedDevices
%         dist = distToAgg(j);
        %dist = sqrt(sum((posDevices(j)-posAggregators(i)).^2));

        % Clean up and get only those positions that are active
        arrivals = USERS(j).reportSuccesses;
        typeArrivals= USERS(j).reportArrivalTypes;
        data = USERS(j).reportDatasize;

        arrivalsBuf = [arrivalsBuf, arrivals];
        typeOfArrivalBuf = [typeOfArrivalBuf, typeArrivals];
        dataBuf = [dataBuf,data];
        

%         distances = [distances, dist*ones(size(arrivals))];
    end
    dataBuf(arrivalsBuf == 0) = [];
    typeOfArrivalBuf(arrivalsBuf == 0) = [];
    arrivalsBuf(arrivalsBuf == 0) = [];
    
    if(arrivalsBuf)
        [arrivalsbuf,I] = sort(arrivalsBuf);
        arrivalsbuf = (ceil(arrivalsbuf));
        databuf = dataBuf(I);
        typesbuf = typeOfArrivalBuf(I);

        USERS_LTE(i).reportArrivals(1:numel(arrivalsbuf)) = arrivalsbuf;
        USERS_LTE(i).reportArrivalTypes(1:numel(typesbuf)) = typesbuf;
        USERS_LTE(i).reportDatasize(1:numel(databuf)) = databuf;

        USERS_LTE(i).PREAMBLES = Preambles(i,:);
        USERS_LTE(i).nextRACH = arrivalsbuf(1) + find( RAO(arrivalsbuf(1):(arrivalsbuf(1)+20)) > 0,1) - 1; % nextRACH should match a RAO
        USERS_LTE(i).nextPreamble = Preambles(i,1);
    end
% %             Setup for the Initial RACH
% %             USERS(i).nextTX = arrivalsBuf(1);% + find( RAO(arrivalsBuf(1):arrivalsBuf(1)+20) > 0,1) - 1; % nextRACH should match a RAO
% %             USERS(i).nextPreamble = Preambles(i,1);
end