function [pdcchPositions, neededCCEs, modulationSelected, peTX, phyOK] = processPHY( message, enb, remainingCCEs, pdcchBits, Parameters)
% For the time being just sustract two CCEs per PHY Message. (Format 1)
phyOK             = 0;
pdcchPositions    = 1; % Not implemented yet.

[modulationSelected, peTX] = amcPHY(message, Parameters);
switch (message.phy.PDCCHFormat)
     case -1
         neededCCEs = 0;
         phyOK = 1;
     case 1
         neededCCEs = 2;
         if ( remainingCCEs >= neededCCEs )        
             phyOK         = 1;
         end
     otherwise
         error('Only PDCCH Format 1 Supported');     
end

end % function