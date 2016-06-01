function capacityPerRB = prbULCapacity(ue, pusch, modulation, codingRate)
% Count number of bits per resource element in the grid at each subframe.
% Returns matrix M x N, where M is the number of PRBs per subframe and N is
% the number of subframes in the grid (recommended 10).


%% SHORTCUT
capacityPerRB    =  double(modulation) * 144 * ones(ue.NULRB-ue.RAO, 1);

%% REAL THING
% 
% pusch.Modulation = modulation;
% capacityPerRB    = zeros(ue.NULRB, totalSubframes);
% for i=0:totalSubframes-1
%     % TODO: Include overhead in the uplink.
%     capacityPerRB(:,i+1) = 36 * 8 * ones(ue.NULRB, 1); 
% end

end % function