function debuggingQueue(messages,sentMsgs, trackID, USERS, sfn,Parameters)

numMsgs = 100; % Display up to numMsg

lastMsg = min(numMsgs,numel(messages));

vline = ['|', '|', '|', '|', '|', '|', '|']';
hline = ['-------------------------'];
% clc;
% disp('-------------------------------------------------------');
% disp('|                                                     |');
% disp(['|                      SFN: ',num2str(sfn), '                      |']);
% disp(['|                  Sent Messages: ',num2str(numel(sentMsgs)), '                   |']);
% disp('-------------------------------------------------------');
fID = fopen('QueueDebug6.txt','a');
fprintf(fID, '-------------------------------------------------------');
fprintf(fID, '|                                                     |');
fprintf(fID, ['|                      SFN: ',num2str(sfn), '                      |']);
fprintf(fID, ['|                  Sent Messages: ',num2str(numel(sentMsgs)), '                   |']);
fprintf(fID, '-------------------------------------------------------');
for i=1:lastMsg
    
    sent = find(sentMsgs==i, 1);
    fragmented = messages(i).mac.fragmented;
    
    if (fragmented)
        dispColor = 'magenta';
    elseif(~isempty(sent))
        dispColor = 'green';
    else
        dispColor = 'black';
    end
    
    if (messages(i).mac.UID == trackID)
        dispColor= 'red';
    end
%     [USERS(messages(i).mac.UID).reportIndex];
    stringText = ['UID: ', num2str(messages(i).mac.UID), ' I: ',num2str([USERS(messages(i).mac.UID).reportIndex]), '\n' ...
                  'Payload: ', num2str(messages(i).mac.payload), '\n' ...
                  'TxError: ', num2str(messages(i).errorInTX), '\n' ...
                  'Fragmented: ', num2str(messages(i).mac.fragmented), '\n', ...
                  'Life Left: ', num2str(messages(i).timer - (sfn - messages(i).sfn)), '\n' ];
              
    
%     cprintf(dispColor,[hline, '(', num2str(i), ') ', messages(i).mac.type,  hline, '\n']);
%     cprintf(dispColor,stringText);
%     print debug file
    
    fprintf(fID, [hline, '(', num2str(i), ') ', messages(i).mac.type,  hline, '\n']);
    fprintf(fID, stringText);
%     
    disp('');
    
end
fclose(fID);
