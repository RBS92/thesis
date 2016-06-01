function USERS = storeLastMessage(USERS, string, message)

UID = message.mac.UID;
for i=1:numel(UID)
    %USERS(UID(i)).lastMessage = [USERS(UID(i)).lastMessage,
    %string,message.mac.type]; % Better debugging, slower simulation.
    USERS(UID(i)).lastMessage = [string, message.mac.type];
%     display(['RLC: ',num2str(USERS(UID(i)).RLC),' index: ',num2str(USERS(UID(i)).reportIndex)])
end
end
