function capacityPerRB = prbDLCapacity(enb, pdsch, modulation, codingRate)
% Count number of bits per resource element in the grid at each subframe.
% Returns matrix M x N, where M is the number of PRBs per subframe and N is
% the number of subframes in the grid (recommended 10).

% SHORTCUT
capacityPerRB    =  double(modulation) * 144 * ones(enb.NDLRB, 1);

%% REAL THING
% pdsch.Modulation = modulation;
% capacityPerRB    = zeros(enb.NDLRB, totalSubframes);
% for i=0:totalSubframes-1
%     enb.NSubframe = i;
%     for j=0:enb.NDLRB-1
%         [~, pdschIndInfo] = ltePDSCHIndices(enb,pdsch,j,{'1based'});
%         capacityPerRB(j+1,i+1) = round(pdschIndInfo.G * codingRate);
%     end
% end

end % function