function splitChannelsBatchMode
% Lilia Mesina, Polaris/CCBN, July2015
% ==

%%test
%c3d -mcs 111_x2.5_z0b.tif -oo blue.tif green.tif red.tif
%image with c3d are 4x bigger, strange -> use MIJI and batch

%% select Sections for registration
dn = uigetdir('',...
    'Select ndpi4regis directory to open');
if isequal(dn,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', dn])
end

%test dn = 'X:\Processed\ndpi4regis\'; %p2003, z: for p1708
flipYes = [];
k = 0;
saveFN = [dn '/sectionFlipInfo.mat'];

if exist (saveFN, 'file')
    load(saveFN, 'flipYes');
end

list = dir(dn);
Miji(false);
%%
n = length(list);
for i = 1:n
    fn = list(i).name;
    fn0 = [dn fn];
    if ~isdir(fn0) || strcmp(fn,'.') || strcmp(fn,'..')
        disp([fn ' not a folder, skip.']);
        continue
    end
    fn2 = str2num(fn);
    if ~isempty(fn2) && isa(fn2,'numeric') && mod(fn2,1)==0
        disp([fn ' ==> process section.']);
        fList = dir([fn0 '\' fn '*_x2.5_z0b.tif*']); 
        if isempty(fList), continue; end
        imgS =  [fn0 '\' fList(1).name]; %do all?
        mijread(imgS); 
        
        choice = questdlg(['Flip section ' fn0 '?'], ...
	                       'Flip','Yes','Quit','No','No');
        switch choice
        case 'Yes'
             disp(['Flip section ' fn0 '.'])
             flipY = 1;
        case 'No'
             flipY = 0;
        case 'Quit'
             break;
        end
        if flipY
            MIJ.run('Flip Horizontally', '');
        end
        k = k+1;
        flipYes(k, 1:2) = [fn2 flipY];
        %imp = IJ.openImage(imgS);
        imgS1 = [fn0 '\' fn '_x2.5.tif'];
        paraS1 = ['[path=''' imgS1 ''']'];
        MIJ.run('Save', paraS1)
        %IJ.saveAs(imp, 'Tiff', imgS');
        MIJ.run('Split Channels', '');
        imgS2 = [fn0 '\' fn '_x2.5B.tif'];
        paraS2 = ['[path=''' imgS2 ''']'];
        MIJ.run('Save', paraS2)
   
    disp(['Image saved in ' imgS2]);
    MIJ.run('Close')   

    else
        disp([fn ' not a integer, skip.']);
    end
    MIJ.run('Close All'); % doesn't close Exception window
    %if i == 2, break; end 
end

save(saveFN, 'flipYes');
MIJ.run('Close All'); % doesn't close Exception window
MIJ.exit;
