function [parbuf] = prepareBuffers(parbuf)

parbuf.latencyUncertainty      = [inf,-inf];
parbuf.outageUncertainty       = [inf,-inf];
parbuf.throughputUncertainty   = [inf,-inf];
parbuf.goodputUncertainty      = [inf,-inf];
parbuf.efficiencyULUncertainty = [inf,-inf];
parbuf.efficiencyDLUncertainty = [inf,-inf];
parbuf.failuresUncertainty     = [inf,-inf];
parbuf.probCollisionUncertainty= [inf,-inf];
parbuf.lagOutUncertainty       = [inf,-inf];