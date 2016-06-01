function [C] = capacity(SF,CR,BW)
RC = 4./(4+CR);

for i = 1:numel(CR)
    C(i,:) = SF.*RC(i)./((2.^SF)./BW);
end