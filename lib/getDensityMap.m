function getDensityMap(dn, nS, sectList, iCase)
% Aaron W, Apr2014

disp(['== Start getDensityMap, iCase' num2str(iCase)]);

%% init
switch iCase
            case 1
                fileName  = '\flatDist_red_in_LeftHDeep.mat';
                fileName2 = '\flatDist_red_in_LeftHSup.mat';
            case 2
                fileName  = '\flatDist_red_in_RightHDeep.mat';
                fileName2 = '\flatDist_red_in_RightHSup.mat';
            case 3
                fileName  = '\flatDist_green_in_LeftHDeep.mat';
                fileName2 = '\flatDist_green_in_LeftHSup.mat';
            case 4
                fileName  = '\flaDist_green_in_RightHDeep.mat';
                fileName2 = '\flaDist_green_in_RightHSup.mat';
end    

%% load data and init vars 
CountPix = [];
i = 0;
for k = 1:nS
    sect = sectList(k);
    dName  = [dn num2str(sect) '\analysis2\'];    
    fileN  = [dName fileName]; fileN2 = [dName fileName2];
    if ~exist(fileN,'file') || ~exist(fileN2,'file'), continue; end

    i = i + 1;
    dataS = load(fileN);
    flatData = [];
    flatData = dataS.flatDistD;
    dataS2 = load(fileN2);
    flatData2 = [];
    flatData2 = dataS2.flatDistS;
    flatData2 = [flatData flatData2];
    flatDataSD{i} = sort(flatData2);
%AW added
    FlatDataAll{i} = flatDataSD{i};
    maxPix(i) = max(flatDataSD{i});
    minPix(i) = min(flatDataSD{i});
    CountPix(i) = length(flatDataSD{i});

    Label{i} = sect; %dName;     
end

if i == 0
    disp(['No data for Density Map with iCase:' num2str(iCase)]);
    return
end
maxAll = max(maxPix);
minAll = -1e4;%min(minPix); 

BinSize = 1e4/5;
Edges = (minAll:BinSize:maxAll);

%% get Density
Density = zeros(length(Edges));
for k = 1:i
     %CountPix(i) = (length(flatDataSD));
     Density = histc(flatDataSD{k},Edges);
     DensityMatrix{k} = Density;
end

CountAll = sum(CountPix);
DensityMatrixStrct = zeros(length(Edges),i);
for j = 1:i
    DensityMatrixStrct(1:length(Edges),j) = DensityMatrix{j};
end

DensityMatrixStrct = DensityMatrixStrct./CountAll;
DensityMatrixStrct = rot90(DensityMatrixStrct);
%figure(2)
pcolor(DensityMatrixStrct)