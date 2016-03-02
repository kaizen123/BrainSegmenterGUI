function saveData(channel, side, data)
% Lilia Mesina, Polaris/CCBN, November2013
% ==
% Last Modified by LM, 10Jul2014

global batchRoot dataCompute


str1 = [batchRoot 'analysis2\' dataCompute '_'];
s = [channel side];
switch s
    case 'RedL'
            fn = [str1 'Red_in_LeftH.mat'];
    case 'RedR'
            fn = [str1 'Red_in_RightH.mat'];
    case 'GreenL'
            fn = [str1 'Green_in_LeftH.mat'];
    case 'GreenR'
            fn = [str1 'Green_in_RightH.mat'];
    otherwise
       errordlg('Can''t decide on Left/Right in func saveData.');
end
if ~exist([batchRoot 'analysis2'], 'dir')
    mkdir(batchRoot,'analysis2');
end
save(fn, 'data');
disp(['Distance saved. File ' fn]);
