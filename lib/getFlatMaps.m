function getFlatMaps()
%% Last Modified by LM, Jan2014

%% select Processed Sections
dn = uigetdir('C:\', 'Select Processed directory to open');
if isequal(dn,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', dn])
end

%% get sectList
%4test   dn = 'V:\analysisAll'; 
%[dn fn ext] = fileparts(dn); 
%sectList = [10; 25; 79; 109; 115; 187; 193; 199; 211; 217]; %importdata([dn '\' fn]);

sectList0 = dir(dn);
sectList = []; 
for i = 1:length(sectList0)
    dnVar0 = str2num(sectList0(i).name);
    dnVar = dnVar0; %dnVar0(1);
    if ~isempty(dnVar) && isa(dnVar,'numeric')
        %j = j + 1; %sectList(j) = {dnVar0}; 
        sectList = [sectList, dnVar0];
    end
end
%sectList = sectList';
sectList = sort(sectList);
nS = length(sectList);
lastSect = sectList(nS);
lastSect = lastSect + 1;
maxL = max(sectList);

%% init Figure
hD = findobj('Tag', 'tracerPlotAll');
if isempty(hD)
    hD = figure('Tag', 'tracerPlotAll', 'Name', 'Tracer Plot', 'NumberTitle','off');
end

%h1 = subplot(2,2,1);
h1 = subplot('Position',[0.16, 0.58, 0.33, 0.33]);
h2 = subplot('Position',[0.52, 0.58, 0.33, 0.33]);
h3 = subplot('Position',[0.16, 0.13, 0.33, 0.33]);
h4 = subplot('Position',[0.52, 0.13, 0.33, 0.33]);

for i=1:4
    switch i
        case 1
            strT = 'Red Tracer';
            hP = h1;            
        case 2
            strT = ''; %'Tracer';
            hP = h2;            
        case 3
            strT = 'Green Tracer';
            hP = h3;            
        case 4
            strT = ''; %'Tracer';
            hP = h4;  
    end
    subplot(hP); 
    plot(hP,0, 0, 0, maxL,'b-', 'MarkerSize',10,'LineWidth',4);
    hT = title(strT);
    set(hT,'FontWeight','bold','horizontalAlignment', 'center','units', 'normalized');
    hT1 = get(hT, 'position');
    set(hT, 'position', [1 hT1(2) hT1(3)]);
    hold on       
end

figure(hD);
yVal = sectList';
subplot(h1);
set(gca,'XDir','reverse');
set(h1,'yTick',yVal,'FontSize',7,'YAxisLocation','left');
set(h2,'yTick',yVal,'FontSize',7,'YAxisLocation','right');
%set(h2,'ygrid','on');
subplot(h3);
set(gca,'XDir','reverse');
set(h3,'yTick',yVal,'FontSize',7,'YAxisLocation','left');
set(h4,'yTick',yVal,'FontSize',7,'YAxisLocation','right');

%% Plot Data
dn = [dn '\'];
nS2 = nS;
for k = 1:nS
    sect = sectList(k);
    dName = [dn num2str(sect) '\analysis2'];
    if ~exist(dName,'dir')
        nS2 = nS2 - 1;
        continue; 
    end
    
    for i=1:4
        switch i
            case 1
                hP = h1; 
                fileN  = [dName '\flatDist_red_in_LeftHDeep.mat'];
                fileN2 = [dName '\flatDist_red_in_LeftHSup.mat'];
  %              getData = 'distData = dataS.distOfRed_InLeft;';
            case 2
                hP = h2; 
                fileN  = [dName '\flatDist_red_in_RightHDeep.mat'];
                fileN2 = [dName '\flatDist_red_in_RightHSup.mat'];
            case 3
                hP = h3; 
                fileN  = [dName '\flatDist_green_in_LeftHDeep.mat'];
                fileN2 = [dName '\flatDist_green_in_LeftHSup.mat'];
            case 4
                hP = h4; 
                fileN  = [dName '\flaDist_green_in_RightHDeep.mat'];
                fileN2 = [dName '\flaDist_green_in_RightHSup.mat'];
        end
    subplot(hP);
    flatData = [];
    if exist(fileN,'file')
        dataS = load(fileN);
        flatData = dataS.flatDistD;
    else
        disp(['No file ' fileN]);
    end
    flatDataSup = [];
    if exist(fileN2,'file')
        dataS = load(fileN2);
        flatDataSup = dataS.flatDistS;
    else
        disp(['No file ' fileN2]);
    end
    %eval(getData); %!too many mat files already generated, ...
    if ~isempty(flatData)
        refP2 = flatData(end);
        plot(flatData,sect,'g.');
        allP = length(flatData);
        disp(['S' num2str(sect) 'Deep plot ' num2str(allP) ' points. Case i=' num2str(i) ]);
        plot(0,sect,'b.');
        plot(refP2,sect,'r.');
    end
    hold on
    if ~isempty(flatDataSup)
        sect2 = sect + 1;
        refP2 = flatDataSup(end);
        plot(flatDataSup,sect2,'g.');
        allP = length(flatDataSup);
        disp(['S' num2str(sect2) 'Sup plot ' num2str(allP) ' points. Case i=' num2str(i) ]);
        plot(0,sect2,'b.');
        plot(refP2,sect2,'r.');
    end
    hold on
    end
end

%% Plot final Figure
linkaxes([h1 h2 h3 h4], 'xy');
subplot(h1); plotGreyAxes;
subplot(h2); plotGreyAxes;
subplot(h3); plotGreyAxes;
subplot(h4); plotGreyAxes;
figure(hD);
disp(['=== Plot Flat Maps: Done. Total sections: ' num2str(nS2) ' from ' num2str(nS)]);

%% plot Density Maps
figure('Name','Red Left Density Map 1', 'NumberTitle', 'off')
getDensityMap(dn, nS, sectList, 1);

figure('Name','Red Right Density Map 2', 'NumberTitle', 'off')
getDensityMap(dn, nS, sectList, 2);

figure('Name','Green Left Density Map 3', 'NumberTitle', 'off')
getDensityMap(dn, nS, sectList, 3);

figure('Name','Green Right Density Map 4', 'NumberTitle', 'off')
getDensityMap(dn, nS, sectList, 4);
