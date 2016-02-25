function getGUIcounts
%% LM, feb2015
global brainRoot

if isempty(brainRoot)
    brainRoot = uigetdir();
end
hB = waitbar(0, 'Get cell counts...');
[dn fn ex] = fileparts(brainRoot);
brainID = fn;
dn = [brainRoot '\processed\'];
fnCounts = [dn brainID '_GUIcellCounts.xlsx'];
sList = getProcessedSectionList(dn);
sList2 = sList';
d = {'Section' 'totalB' 'totalR' 'totalG' 'inROI_B' 'inROI_R' 'inROI_G'};
xlswrite(fnCounts, d, 1, 'A1');
n = length(sList);
d = zeros(n,4);
for i = 1:n
    sNumber = sList(i);
    sName = num2str(sNumber);    
    fn = [dn sName '\allData.mat'];
    if ~exist(fn, 'file')
        disp(['No .mat file in folder ' sName ', skeep.']);
        d(i,:) = [sNumber 0 0 0];
    else
        load(fn);
        allR = length(allData(allData(:,3)>0));
        allG = length(allData(allData(:,4)>0));
        allB = length(allData(:,1));%allData(allData(:,5)>0);
        d(i,:) = [sNumber allB allR allG];
    end
    waitbar(i/n, hB, 'Get cell counts...');
end
xlswrite(fnCounts, d, 1, 'A2');
waitbar(1, hB, 'Get cell counts...');
close(hB);
disp(['Data saved to Excel file ' fnCounts])

