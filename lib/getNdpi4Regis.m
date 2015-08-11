function getNdpi4Regis()
% Lilia Mesina, Polaris/CCBN, March2015
% ==
% Last Modified by LM, 20Apr2015
global brainRoot

%%
if isempty(brainRoot)
    dn = uigetdir('Select brain directory to open');
    if isequal(dn,0)
        disp('User selected Cancel');
        return
    else
        disp(['User selected ', dn])
    end
    brainRoot = dn;
    return
end
dn = [brainRoot '\Processed\'];

outF = []; 
procF = [pwd '\ndpisplit-mJ.exe '];

diary on;
logF = [dn '\runLog_getNdpi4Regis.txt'];
diary logF;
disp(['Run getNdpi4Regis.m / Date: ' datestr(now) '/ User: ' getenv('username')]);

sectList0 = dir(dn);
sectList = []; 
j = 0;
for i = 1:length(sectList0)
    dnVar0 = sectList0(i).name;
    %dnVar  = str2num(dnVar0); %dnVar0(1);
    if isdir([dn dnVar0]) %% && isa(dnVar,'numeric')
        j = j + 1;
        sectList{j} = dnVar0;
    end
end
%sectList = sectList';
%%sectList = sort(sectList);

nS = length(sectList);
hB = waitbar(0, 'Step0 in progress ...');

for k = 1:nS
    dnVar = sectList{k};
    dName  = [dn dnVar '\'];
    dName2 = dir([dName '\batch*']);
    if isempty(dName2), continue; end
    dName2 = dir([dName '\*.ndpi']);
    if isempty(dName2), continue; end
    if length(dName2) > 2 %1
        disp(['Skip folder, more than 2 ndpi file in ' dName]); 
        continue
    end
    fName0 = dName2(1).name;
    [d0 n0 e0] = fileparts(fName0);
    n1 = str2num(n0);
    %if n1 > 10, continue; end; % only first 10sections
    if ~isa(n1,'numeric')
        fName0 = dName2(2).name;
        [d0 n0 e0] = fileparts(fName0);
        n1 = str2num(n0);
        if ~isa(n1,'numeric')
            disp(['None ndpi file has numeric name. Skip folder ' d0]);
            continue
        end
    end
    disp(['Start ' fName0]);
    fName = [dName fName0];
    outF = [dName '/regis'];
    if (~exist(outF, 'dir'))
        [pth name] = fileparts(outF); 
        [status, errstr] = mkdir(pth, name);
        if status==0
            error(errstr) 
        end;
    end;
    dName2 = dir([outF '\*_x10_z0.tif']);
    if ~isempty(dName2) 
            disp('Already done, skip.');
            continue
    end

    fNameNew = [outF '\' fName0];
    copyfile(fName, fNameNew);
    [status, echo1] = dos([procF fNameNew], '-echo'); %err if on huxley
    if status
        disp(['==ndpisplit errror. Skip ' fName0]);
        continue
    end
    delete([outF '\' '*.ndpi']); 
    delete([outF '\' '*.jpg']); 
    delete([outF '\' '*_x40_*.tif']); 
    delete([outF '\' '*macro.tif']); 

    disp(['Done ' fName0]);
    waitbar(k/nS, hB, 'Step0 in progress ...');
    if k >= 5,     break;     end
end
waitbar(1, hB, 'Step0 in progress ...');
close(hB);
disp('==Done all sections.');
diary logF;
diary off;
disp(['==Log saved to ' logF]);