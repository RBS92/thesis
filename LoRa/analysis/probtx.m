function [p_tx] = probtx(SFs,SFsB,SFx,B,N)

avail = (B <= SFsB);
% SFs
% avail
if(any(SFs(avail)==SFx))
    C = 1/sum(avail);

    p_tx = C * (1-C)^(N-1) * (1-C)^(N-1) * N;

else
%     C = 0;
    p_tx = 0;
end
   

end