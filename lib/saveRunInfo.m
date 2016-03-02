function saveRunInfo(startTime)
%% Lilia Mesina, CCBN, feb2015
global batchRoot step

fn = [batchRoot '\runInfo.txt'];
fileID = fopen(fn,'a');
endTime = datetime;
runTime = endTime-startTime;
startStr =  datestr(startTime);
endStr = datestr(datetime);
runStr = char(runTime);

c = char(java.net.InetAddress.getLocalHost.getHostName);

str = [step '     ' c '     ' startStr '     ' endStr '     ' runStr];
fprintf(fileID,'%s\r\n', str);
fclose(fileID);

% if exist(fn, 'file') 
%    xlsappend(fn, str);
% else 
%    xlswrite(fn, str, 'A1');
% end