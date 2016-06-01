function [arrivalsBuf,typeOfArrivalBuf, failedArrivals, failedType] = UEtoAggComm(arrivalsBuf, typeOfArrivalBuf, distances, Parameters)

%% Communication model
% Put some form of communications model
%  step 1) All arrivals goes in

%  step 2) Some arrivals fail based on error rate

%  step 3) Latencies for the arrivals are calculated (either fixed or
%  pickded from some distribution)

%  step 4) save stats for all who failed etc.

% SNR calculation
% 
PL = 20*log10(distances) + 20*log10(Parameters.UE2AggComm.freq)-27.55
shadow = lognrnd(Parameters.phy.shadowMean,Parameters.phy.shadowVar);   % Shadowing
R = pow2db(raylrnd(Parameters.phy.raylVar)); %Rayleigh fading

SNRb =  Parameters.UE2AggComm.TXpow - PL - Parameters.phy.noise + shadow + R - pow2db(2)

% Pb calculation
Pb = qfunc(sqrt(2*db2pow(SNRb)))

Psuccess = (1-Pb).^Parameters.UE2AggComm.TXsize;

sucesses = (rand(size(distances))<Psuccess);

failedArrivals  = arrivalsBuf(~sucesses);
failedType      = typeOfArrivalBuf(~sucesses);
arrivalsBuf     = arrivalsBuf(sucesses);
typeOfArrivalBuf= typeOfArrivalBuf(sucesses);