function [Parameters] = saveStats(Parameters, message)

Parameters.stats.txErrors = Parameters.stats.txErrors + message.stats.txErrors;
Parameters.stats.correctMSG3 = Parameters.stats.correctMSG3 + message.stats.correct;
Parameters.stats.collidedMSG3 = Parameters.stats.collidedMSG3 + message.stats.collission;
Parameters.stats.notenoughCCEs = Parameters.stats.notenoughCCEs + message.stats.notenoughCCEs;
Parameters.stats.notenoughRBs = Parameters.stats.notenoughRBs + message.stats.notenoughRBs;
Parameters.stats.noTX = Parameters.stats.noTX + 1;

if(message.stats.RRC)
    Parameters.stats.RRCtxErrors = Parameters.stats.RRCtxErrors + message.stats.txErrors;
    Parameters.stats.RRCcorrectMSG3 = Parameters.stats.RRCcorrectMSG3 + message.stats.correct;
    Parameters.stats.RRCcollidedMSG3 = Parameters.stats.RRCcollidedMSG3 + message.stats.collission;
    Parameters.stats.RRCnotenoughCCEs = Parameters.stats.RRCnotenoughCCEs + message.stats.notenoughCCEs;
    Parameters.stats.RRCnotenoughRBs = Parameters.stats.RRCnotenoughRBs + message.stats.notenoughRBs;
    Parameters.stats.RRCnoTX = Parameters.stats.RRCnoTX + 1;
end