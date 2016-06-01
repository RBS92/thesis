clear all
% close all
clc

%% LoRa - Analysis results
BW = 125*10^3;
n_ch = 16;
SFs = [7:12];
SFsB = [222,222,115,51,51,51]+12;
SFsS = [-123 -126 -129 -132 -134.5 -137];
CRs = 1:4;
Ptx = 14;
Pn = -174+10*log10(BW);
cell_r = 1000;
n = 4; %pathloss exponent

B = 20+12; % payload
% B=B*8; %payload in bits
N = [1:250]; %active users in a channel


collissionmodel = 1;
errormodel = 0;

C_sfs_max = capacity(SFs,CRs,BW);
C_ch_max = sum(capacity(SFs,CRs,BW),2);
C_ch_avg = C_ch_max;
C_sfs_avg = C_sfs_max;

%Latency
ms_sfs_max = (B*8)./C_sfs_max;
Rs = BW./(2.^SFs); %symbol rate
txpreamp = repmat(8*1./Rs,4,1);% preamble tx time

ms_sfs_max = ms_sfs_max + txpreamp;

%% V1
% for k = 1:numel(N)
% 
%     if(collissionmodel)
% %         p_e = zeros(1,);
%         if(errormodel)
%         %error model
%             E_tx_d = sqrt(1/2)*cell_r;
%             E_P_pl = 10*n*log10(E_tx_d);
%             Pi = pow2db(db2pow((Ptx-E_P_pl))*(N(k)-1));
%             Pi(Pi == -Inf) = 0;
%             SINR = (Ptx - E_P_pl) - Pn -Pi;
%             p_e = proberr(SFsS,SINR);
%         end
%         % collission model
%         for i = 1:numel(SFs)
%             Nsf = N(k)*(ms_sfs_max(1,i)./ms_sfs_max(1,numel(SFs)));
%             p_tx = probtx(SFs,SFsB,SFs(i),B,Nsf)
% %             Nsf = N(k)/6*ms_sfs_max(1,i);
% %             ptx = 2*Nsf*exp(-2*Nsf)
% %             if(errormodel)
% %                 C_ch_avg_col(:,i) = capacity(SFs(i),CRs,BW).*p_tx.*(1-p_e(i));
% %             else
%                 C_ch_avg_col(:,i) = capacity(SFs(i),CRs,BW).*p_tx;
% %             end
%     %         C_sfs_avg(i) = C_sfs_max(i)*p_tx;
%         end
%         C_ch_avg = sum(C_ch_avg_col,2);
%     end
%     C_ch_max_buf = sort(capacity(SFs,CRs,BW),2,'descend');
%     C_system_max(:,k) = sum(C_ch_max_buf(:,1:(k*(k<=numel(SFs))+numel(SFs)*(k>numel(SFs)))),2)*n_ch;
%     C_system_avg(:,k) = C_ch_avg*n_ch;
% end

%% V2
N = [52200];
Nch = N/n_ch;
Nsf = Nch/numel(SFs);
lambda = 0.00000:0.00001:.1;
for j = 1:numel(N)
for k = 1:numel(lambda)

    if(collissionmodel)
        % collission model
        for i = 1:numel(SFs)
            L = Nsf(j)*lambda(k)*ms_sfs_max(1,i);
            p_tx = exp(-2*L);
            through = L*exp(-2*L);
%             if(errormodel)
%                 C_ch_avg_col(:,i) = capacity(SFs(i),CRs,BW).*p_tx.*(1-p_e(i));
%             else
            C_ch_avg_col(:,i) = capacity(SFs(i),CRs,BW).*through;%capacity(SFs(i),CRs,BW).*p_tx;
%             end
    %         C_sfs_avg(i) = C_sfs_max(i)*p_tx;
        end
        C_ch_avg = sum(C_ch_avg_col,2);
%         Throughput(k,j) = through()
    end
    
    C_ch_max_buf = sort(capacity(SFs,CRs,BW),2,'descend');
    C_system_max(:,k,j) = sum(C_ch_max_buf,2);
%     C_system_max(:,k) = sum(C_ch_max_buf(:,1:(k*(k<=numel(SFs))+numel(SFs)*(k>numel(SFs)))),2)*n_ch;
    C_system_avg(:,k,j) = C_ch_avg;
end
end

% C_ch_avg = sum(capacity(SFs,CRs,BW).*(1-P_col).*(1-P_error),2)

%% Post processing
figure
hold on
plot([lambda]*Nch, [C_system_avg(:,:,1)]')
% plot([lambda], [C_system_avg(:,:,2)]')
plot([lambda]*Nch,[C_system_max(:,:,1)]'*0.18)
legend('R - CR 1 - N = 52200','R - CR 2 - N = 52200','R - CR 3 - N = 52200','R - CR 4 - N = 52200','C - CR 1','C - CR 2','C - CR 3','C - CR 4','Sim R - CR 2')
title('LoRa capacity for single channel')
xlabel('Aggregated Arrival rate')
ylabel('Capacity and rates [b/s]')
xlim([0 250])

% %% V2.1
% N = 100:52200;
% Nch = N/n_ch;
% Nsf = Nch/numel(SFs);
% lambda = 0.01;
% for k = 1:numel(N)
% 
%     if(collissionmodel)
%         % collission model
%         for i = 1:numel(SFs)
%             L = Nsf(k)*lambda*ms_sfs_max(1,i);
%             p_tx = exp(-2*L);
%             if(errormodel)
%                 C_ch_avg_col(:,i) = capacity(SFs(i),CRs,BW).*p_tx.*(1-p_e(i));
%             else
%                 C_ch_avg_col(:,i) = capacity(SFs(i),CRs,BW).*p_tx;%capacity(SFs(i),CRs,BW).*p_tx;
%             end
%     %         C_sfs_avg(i) = C_sfs_max(i)*p_tx;
%         end
%         C_ch_avg = sum(C_ch_avg_col,2)/numel(SFs);
%     end
%     C_ch_max_buf = sort(capacity(SFs,CRs,BW),2,'descend');
%     C_system_max(:,k) = sum(C_ch_max_buf*n_ch,2);
% %     C_system_max(:,k) = sum(C_ch_max_buf(:,1:(k*(k<=numel(SFs))+numel(SFs)*(k>numel(SFs)))),2)*n_ch;
%     C_system_avg(:,k) = C_ch_avg;
% end
% 
% % C_ch_avg = sum(capacity(SFs,CRs,BW).*(1-P_col).*(1-P_error),2)
% 
% %% Post processing
% figure
% hold on
% plot([0 N], [C_system_avg(:,1) C_system_avg]')
% % plot([0 lambda]*n_ch,[C_system_max(:,1) C_system_max]')
% legend('R - CR 1','R - CR 2','R - CR 3','R - CR 4','C_{max} - CR 1','C_{max} - CR 2','C_{max} - CR 3','C_{max} - CR 4')
% title('LoRa Outage and capacity in 16 channels')
% xlabel('Active transmissions')
% ylabel('Capacity and rates [b/s]')
% xlim([0 52000])


% figure
% hold on
% plot([0 lambda], [C_system_max(:,1)/n_ch C_system_avg/n_ch]')
% plot([0 lambda],[C_system_max(:,1)/n_ch C_system_max/n_ch]')
% legend('R - CR 1','R - CR 2','R - CR 3','R - CR 4','C_{max} - CR 1','C_{max} - CR 2','C_{max} - CR 3','C_{max} - CR 4')
% title('LoRa Outage and capacity in a single channel')
% xlabel('Active transmissions')
% ylabel('Capacity and rates [b/s]')
% xlim([0 10])
%%
N = 1000;
Nch = N/16;
LAMBDA = 0.00001:0.00001:1;
for lamb = 1:numel(LAMBDA)
    for i = 1:numel(SFs)
%         temporalratio = double(ms_sfs_max(2,i)./ms_sfs_max(2,numel(SFs)));
    %     temporalratio = 1;
        Nsf = (Nch/6)*LAMBDA(lamb)*ms_sfs_max(2,i);
        pnotx = exp(-2*Nsf);
%         ptx = 2*Nsf*exp(-2*Nsf);
        prob_col(i,lamb) = 1-pnotx;
%         prob_col(i,N) = probcol(SFs,SFsB,SFs(i),B,Nsf);
    end
end
%%
% %%
% Ni = 1:10000;
% for N = Ni
%     for i = 1:numel(SFs)
%         temporalratio = double(ms_sfs_max(2,i)./ms_sfs_max(2,numel(SFs)));
%     %     temporalratio = 1;
%         Nsf = (N/16/6)*temporalratio;
%         prob_col(i,N) = probcol(SFs,SFsB,SFs(i),B,Nsf);
%     end
% end
% % sim = [0.0798    0.1355    0.2184    0.3921    0.5759    0.8068];
% % sim = [0.0206    0.0621    0.1737    0.4141    0.7506    0.9647];
figure
plot(LAMBDA*N,prob_col)
legend('SF 7','SF 8','SF 9','SF 10','SF 11','SF 12')
xlabel('Arrival rate')
ylabel('Probability of collision')
xlim([0 250])
title('Traffic intensity and collission probability')
hold on
% plot(repmat(LAMBDA,1,1),repmat(sim,100000,1)')
% plot(repmat(1/20,1,numel(0:0.001:1)),0:0.001:1)
%%
clear deltax deltay lambda pcolBeta CsfBeta lagBeta ypois
N = 52200*0.05;
Nch = N/n_ch;
x = 0:10000;

% Csfc = [];

for i = 1:numel(SFs)
    
    delta = ms_sfs_max(2,i)*1000*0.5;
    deltax = delta/2:delta:(max(x)-delta/2);
%     figure
    y = betapdf(deltax/max(x),1.859,1.607)/max(x);
%     plot(deltax,y)
    for m=1:numel(deltax)
        x=(m-1)*delta+1:delta*m;
    %     betapdf(x/max(x),1.947,1.702)
        deltay(m) = mean(betapdf(x/max(x),1.947,1.702));
    end
    deltay = betapdf(deltax/max(x),1.947,1.702);
    lambda = deltay.*delta/max(x)*Nch;
    ypois = poissrnd(lambda);
    pcol = [];
    pnotx = [];
    Csfc = [];
    lag = [];
    through = [];
%     lagBeta = [];
%     pcolBeta = [];
%     CsfBeta = [];
    for j = 1:numel(lambda)
    % plot(deltax,ypois/sum(ypois))
%         Nch(j)/delta
        L = lambda(j)*ms_sfs_max(2,i);%*(delta/1000);
    %     Nsf2 = ((Nch/6)-1)*LAMBDA*ms_sfs_max(2,i)

        pnotx(j) = exp(-2*L);
    %     ptx(i) = Nsf*exp(-Nsf);
        through(j) = L*exp(-2*L);
        pcol(j) = 1-pnotx(j);%+(ptx(i));%1-(ptx*pnotx);
    %         prob_col(i,N) = probcol(SFs,SFsB,SFs(i),B,Nsf);
%         capacity(SFs(i),2,BW).*through

        Csfc(j) = capacity(SFs(i),2,BW).*through(j);%capacity(SFs(i),CRs,BW).*p_tx;
%         lag(j) = (1-pcol(j))/sum((1-pcol(j))).*ms_sfs_max(2,i);
    end
    throughBeta(i) = sum(ypois.*through)/sum(ypois);
%     bits(i) = sum(Csfc.*delta);
    pcolBeta(i) = mean(pcol);%sum(ypois.*pcol)/sum(ypois);
%     Csfc
    CsfBeta(i) = mean(Csfc);
%     ypois/sum(ypois).*pcol
%     lagBeta(isnan(lagBeta)) = [];
%     lagBeta
end
throughput = sum(capacity(7:12,2,BW).*throughBeta)
meanpcolBeta = mean(pcolBeta)
% sum(bits)/10
% throughput = sum(CsfBeta)
latencies = ((1-pcolBeta)/sum(1-pcolBeta)).*ms_sfs_max(2,:)*1000;
meanLag = sum(latencies)
% meanLag = mean(lagBeta)*1000
% end
% % Nch(j)
% pcolBeta
% CsfBeta
% lagBeta
% 
% outage = sum(ypois.*pcolBeta)/sum(ypois)
% throughput = mean((ypois/sum(ypois)).*CsfBeta)*16
% meanlatency = mean((ypois/sum(ypois).*lagBeta))
% % N = 52200; % users per channel
% Nch = N/16;
% lag = zeros(1,numel(ypois));
% for j = 1:numel(lamda)
%     for i = 1:numel(SFs)
% %         Nch(j)/delta
%         L = lamda(j)/delta*ms_sfs_max(2,i);
%     %     Nsf2 = ((Nch/6)-1)*LAMBDA*ms_sfs_max(2,i)
% 
%         pnotx(i) = exp(-2*(L));
%     %     ptx(i) = Nsf*exp(-Nsf);
%         through = L*exp(-2*L);
%         pcol(i) = 1-pnotx(i);%+(ptx(i));%1-(ptx*pnotx);
%     %         prob_col(i,N) = probcol(SFs,SFsB,SFs(i),B,Nsf);
%         Csfc(i) = capacity(SFs(i),2,BW).*through;%capacity(SFs(i),CRs,BW).*p_tx;
%         lag(i) = (1-pcol(i))/sum((1-pcol(i))).*ms_sfs_max(2,i);
%     end
%     pcolBeta(j) = mean(pcol);
%     CsfBeta(j) = sum(Csfc);
%     lagBeta(j) = mean(lag)*1000;
% end
% % % Nch(j)
% % pcolBeta
% % CsfBeta
% % lagBeta
% % 
% outage = sum(ypois.*pcolBeta)/sum(ypois)
% throughput = mean((ypois/sum(ypois)).*CsfBeta)*16
% meanlatency = mean((ypois/sum(ypois).*lagBeta))

% % arrivalssec = ypois*1000/delta;
% ypois = ypois/n_ch;
% for j = 1:numel(ypois)
% %     if(j>1)
% %        N = N/2 + ypois(j)
% %     else
% %        N = ypois(j);
% %     end
%     N = ypois(j)/numel(SFs);
%     for i = 1:numel(SFs)
%         temporalratio = (ms_sfs_max(2,i)./ms_sfs_max(2,numel(SFs)));
% %         temporalratio = temporalratio*2;
%         Nsf = N*temporalratio;
% 
%         pnotx = exp(-2*Nsf);
%         ptx = 2*Nsf*exp(-2*Nsf);
%         poisprob_col(i,j) = 1-pnotx-ptx;
% %         poisprob_col(i,j) = double(probcol(SFs,SFsB,SFs(i),B,Nsf));
%     end
% end
% % poisprob_col
% 
% failures = poisprob_col.*double(repmat(ypois/numel(SFs),numel(SFs),1));
% % TXs = repmat(ypois/numel(SFs),numel(SFs),1)
% % outage = sum(poisprob_col,1)
% outage = sum(failures,2)./sum(repmat(ypois/numel(SFs),numel(SFs),1),2);
% % outage = mean(poisprob_col,2)
% bar(SFs,outage)
% hold on
% % [y,x] = hist(SFs{1},7:12);
% % bar(x,(y/REPS)/(TXs/numel(7)))
% plot(7:12,[0.0473    0.0804    0.1581    0.2626    0.4301    0.6220])


%% poisson
% 'MARperiodic', [ ...
% 1   40  20  200     2.5     1/(60*60*24); ...
% 2   40  20  200     2.5     1/(60*60*2); ...
% 3   15  20  200     2.5     1/(60*60); ...
% 4   5   20  200     2.5     1/(60*30); ...
%     ] ...
% );

N = 52200; % users per channel
LAMBDA = 1/10;
Nch = N/16;
Csf = zeros(1,numel(SFs));
for i = 1:numel(SFs)
    L = (0.4*(Nch/6)*1/(60*60*24)+0.4*(Nch/6)*1/(60*60*2)+0.15*(Nch/6)*1/(60*60)+0.05*(Nch/6)*1/(60*30))*ms_sfs_max(2,i);
%     Nsf2 = ((Nch/6)-1)*LAMBDA*ms_sfs_max(2,i)
    
    pnotx(i) = exp(-2*(L));
%     ptx(i) = Nsf*exp(-Nsf);
    through = L*exp(-2*L);
    pcol(i) = 1-pnotx(i);%+(ptx(i));%1-(ptx*pnotx);
%         prob_col(i,N) = probcol(SFs,SFsB,SFs(i),B,Nsf);
    Csf(i) = capacity(SFs(i),2,BW).*through;%capacity(SFs(i),CRs,BW).*p_tx;
end
figure
% bar(7:12,pcol)
% sim = [0.0437    0.0705    0.1256    0.2136    0.3624    0.5714];
% sim = [0.0800    0.1425    0.2360    0.3837    0.5914    0.8105];
% sim = [0.0845    0.1391    0.2342    0.3852    0.5954    0.8094];
% sim = [0.2048    0.3200    0.4648    0.6404    0.8083    0.9536];
% sim = [0.4990    0.7290    0.9163    0.9896    1.0000    1.0000];
% sim = [0.0484    0.0896    0.1570    0.2726    0.4455    0.6958
% sim = [0.2044    0.3858    0.5845    0.7568    0.9293    0.9957];

sim = [0.0163    0.0247    0.0513    0.0903    0.1275    0.2996];
hold on 
bar(7:12,[pcol;sim]')
legend('Analysis','Simulated')
% figure
% bar(7:12,pnotx)
% figure
% bar(7:12,ptx)
outage = sum(pcol)/numel(pcol)*100
latencies = (1-pcol)/sum(1-pcol).*ms_sfs_max(2,:);
meanLag = sum(latencies)*1000
throughput = sum(Csf)*16
