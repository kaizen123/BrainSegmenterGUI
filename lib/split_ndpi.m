function [status nTiles0] = split_ndpi(img)
% Lilia Mesina, Polaris/CCBN, November2013
% ==
% Last Modified by LM, 4Nov2013

global batchRoot batchName homeGUI
%global iMax jMax
%addpath(genpath(dn));

batchNameFull = [batchRoot, batchName];
% if exist(batchNameFull, 'dir')
%     nTiles0 = 0; 
%     status = 0;
%     errordlg(['DIRECTORY: ' batchName ' EXISTS.'],'ERROR');
%     return
% else
%     [pth name] = fileparts(batchNameFull);
%     [status, errstr] = mkdir(pth, name);
%     if status==0    
%         error(errstr) 
%     end;
% end;

[status, echo1] = dos([homeGUI '\lib\3rdparty\ndpisplit-mJ.exe ' img], '-echo'); %err if on huxley
if status, 
    nTiles0 = 0; 
    status = 0;
    errordlg('Can''t run ndpisplit-mJ.exe', 'ERROR'); 
    return 
end
status = 1;

tList = dir([batchRoot '*.jpg']); 
nTiles0 = length(tList);
