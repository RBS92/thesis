function [peTX,modulations] = phyAggUE(distance,Parameters)

alpha = Parameters.UE2AggComm.alpha;
raylStd = Parameters.UE2AggComm.raylStd;
TXpow = Parameters.UE2AggComm.TXpow;
bitErrorTarget = Parameters.UE2AggComm.bitErrorTarget;
noise = Parameters.UE2AggComm.noise;

R = raylrnd(raylStd);
SNR = TXpow+pow2db(R*distance^alpha) - noise;

k = [2,4,6];
M = 2.^k;
Pb=(4./k).*(1-1./sqrt(M)).*(1/2).*erfc(sqrt(3.*k.*db2pow(SNR)./(M-1))./sqrt(2)); %Probability of bit error
i = find(Pb < bitErrorTarget,1,'last');

peTX = Pb(i);
if(k(i))
    switch(k(i))
        case 2,
            modulations = modulation.QPSK;
        case 4,
            modulationSelected = modulation.QAM16;
        case 6,
            modulationSelected = modulation.QAM64;
        otherwise
            error('AMC in amckPHY: modulation not defined')
    end
else
    modulationSelected = modulation.QPSK;
    peTX = Pb(1);
end