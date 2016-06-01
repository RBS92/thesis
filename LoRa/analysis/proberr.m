function [p_e] = proberr(SFsS,SINR)

p_e = (SINR < SFsS);