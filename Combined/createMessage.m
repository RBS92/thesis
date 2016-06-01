function message =  createMessage(uid, sfn,  payload, type, where, modulation, preambles, timer, rnti, pdcchFormat,pos,dataSize)

message.sfn = sfn;      % Subframe number in which was generated

message.timer = timer;  % Expiring time for this message

message.errorInTX = 0;

message.mac = struct( 'UID',                            uid,  ... % User ID
                      'modulation',              modulation,  ... % Modulation to be used {'QPSK', '16QAM', '64QAM'}
                      'payload',                    payload,  ... % Payload in bits
                      'type',                          type,  ... % Type of message MSG2, MSG3, MSG4, etc...
                      'where',                        where,  ... % 'UL' or 'DL' (uplink/downlink)
                      'fragmented',                       0,  ... % Bits of the message has been already transmitted (if fragmented)
                      'numTX',                            1,  ... % Number of time this message has been transmitted
                      'rarIndex',                         1,  ... % Index to indicate how many preambles have been sent RAR response so far (if fragmented)
                      'preambles',                preambles,  ... % Preambles selected by each activeIDs
                      'bundled',                          0   ...
                     );

message.phy = struct( 'RNTI',                  rnti, ... % User ID
                      'PDCCHFormat',    pdcchFormat, ...  % PDCCH Format required for the MAC message.
                      'pos',                    pos,  ... % position                      
                      'peTX',                   0  ... % probability of error
                     );  
                 
message.stats = struct( 'txErrors', 0, ...
                        'correct', 0, ...
                        'collission', 0, ...
                        'notenoughCCEs', 0, ...
                        'notenoughRBs', 0, ...
                        'RRC', 0 ...
                       );               
                 
message.dataSize = dataSize;
end % function