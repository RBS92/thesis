function parbuf = bufferUncertainty(parbuf)

parbuf.latencyUncertainty = [min(parbuf.latencyUncertainty(1,1),parbuf.latencyBuf),max(parbuf.latencyUncertainty(1,2),parbuf.latencyBuf)];
parbuf.outageUncertainty = [min(parbuf.outageUncertainty(1),parbuf.outageBuf),max(parbuf.outageUncertainty(2),parbuf.outageBuf)];
parbuf.throughputUncertainty = [min(parbuf.throughputUncertainty(1),parbuf.throughputBuf),max(parbuf.throughputUncertainty(2),parbuf.throughputBuf)];
parbuf.goodputUncertainty = [min(parbuf.goodputUncertainty(1),parbuf.goodputBuf),max(parbuf.goodputUncertainty(2),parbuf.goodputBuf)];
parbuf.efficiencyULUncertainty = [min(parbuf.efficiencyULUncertainty(1),parbuf.efficiencyULBuf),max(parbuf.efficiencyULUncertainty(2),parbuf.efficiencyULBuf)];
parbuf.efficiencyDLUncertainty = [min(parbuf.efficiencyDLUncertainty(1),parbuf.efficiencyDLBuf),max(parbuf.efficiencyDLUncertainty(2),parbuf.efficiencyDLBuf)];
parbuf.failuresUncertainty = [min(parbuf.failuresUncertainty(1),parbuf.failuresBuf),max(parbuf.failuresUncertainty(2),parbuf.failuresBuf)];
parbuf.probCollisionUncertainty = [min(parbuf.probCollisionUncertainty(1),parbuf.probCollisionBuf),max(parbuf.probCollisionUncertainty(2),parbuf.probCollisionBuf)];