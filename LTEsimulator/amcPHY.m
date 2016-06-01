function [modulationSelected, peTX] = amcPHY(message, Parameters)

if (~Parameters.options.runIdealLink)
    pos = message.phy.pos;
    d = sqrt(norm(pos.^2)); %distance between EnB and the device

    if(strcmp(message.mac.where,'DL'))
        pathloss = 20*log10(d) + 20*log10(Parameters.phy.freqDL)-27.55;   %friis pathloss
        TXpow = Parameters.phy.eNBpow;
    else
        pathloss = 20*log10(d) + 20*log10(Parameters.phy.freqUL)-27.55;   %friis pathloss
        TXpow = Parameters.phy.UEpow;
    end

    shadow = lognrnd(Parameters.phy.shadowMean,Parameters.phy.shadowVar);   % Shadowing

    fastfade = pow2db(raylrnd(Parameters.phy.raylVar)); %Rayleigh fading
    SNR = TXpow - Parameters.phy.noise - pathloss - shadow + fastfade; % SINR in dB

    %SNR = SNR - 10*log10(1/64) - 10*log10(4/5);

    switch (message.mac.type) % user QPSK for signaling and the highest possible for DATA tx
        case 'Data',
            k = [2,4,6];
            M = 2.^k;
            Pb=(4./k).*(1-1./sqrt(M)).*(1/2).*erfc(sqrt(3.*k.*db2pow(SNR)./(M-1))./sqrt(2)); %Probability of bit error
            i = find(Pb < Parameters.phy.bitErrorTarget,1,'last');

            peTX = Pb(i);
            if(k(i))
            switch(k(i))
                case 2,
                    modulationSelected = modulation.QPSK;
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

        otherwise %signaling
            k = 2;
            M=2^k;
            peTX = (4./k).*(1-1./sqrt(M)).*(1/2).*erfc(sqrt(3.*k.*db2pow(SNR)/(M-1))/sqrt(2)); %Probability of bit error
            modulationSelected = modulation.QPSK;
    end
else
   modulationSelected = modulation.QAM64;
   peTX = 0;
end