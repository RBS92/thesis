function [p_col] = probcol(SFs,SFsB,SFx,B,N)

avail = (B <= SFsB);
% SFs
% avail
if(any(SFs(avail)==SFx))
    C = 1/sum(avail);

    p_tx = C * (1-C)^(N-1) * (1-C)^(N-1) * N;
    p_notx = (1-C)^(N);
    if(N<1)
        p_tx = 0;
        p_notx = 1;
    end
    p_col = 1-p_tx-p_notx;

else
%     C = 0;
    p_col = 0;
end
   

end