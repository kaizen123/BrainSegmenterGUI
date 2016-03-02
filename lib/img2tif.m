function [status iMax jMax] = img2tif(imgFN, hB)
% Lilia Mesina, Polaris/CCBN, November2013
% ==
% Last Modified by LM, 26Jun2014

global batchRoot batchName rotate

batchNameFull = [batchRoot, batchName];
batchRoot_ = batchRoot;
if exist(batchNameFull, 'dir')
    iTiles = 0; 
    jTiles = 0; 
    status = 0;
    errordlg(['DIRECTORY: ' batchName ' EXISTS.'],'ERROR');
    return
else
    [pth name] = fileparts(batchNameFull);
    [status, errstr] = mkdir(pth, name);
    if status==0    
        error(errstr) 
    end;
end;

[dn fn ex] = fileparts(imgFN);
tList = dir([dn '\' fn '_x*0_z*.jpg']); 
nT = length(tList);
str1 = batchRoot;
if ~nT
    iTiles = 0; 
    jTiles = 0; 
    status = 0;
    errordlg(['No 40x JPG files exist in directory ' str1],'ERROR');
    return
end


[iMax jMax] = geIJmax(tList);
if strcmp(rotate,'Right') || strcmp(rotate,'Left')
    %because we rotate the image right/left, 
    %iMax and jMax have to switch values
    var1 = iMax;
    iMax = jMax;
    jMax = var1;
end

rotate_ = rotate; % for some reason Miji will clear all global vars  
Miji(false); %it clears global vars, odd

tic
hB = waitbar(0.2, hB, 'Step1 in progress (approx 30min ...)');

for i = 1:nT
    imgT = [str1 tList(i).name];
    [dn tileName ex ] =  fileparts(tList(i).name);
    s1 = strsplit(tileName, '_');
    v = length(s1);
    %v2 = v1-4;
    s2 = s1(v);
    tileFN = s2{1};
    tileFN = ['i' tileFN(2) 'j' tileFN(4)]; 
    mijread(imgT);    
    %%im = imread(imgT);    
    % image will be rotated 90 deg, so ij has to change acordingly in
    %TileName and tileFN
    switch rotate_
    case 'Right'
        iOld = str2num(tileFN(2));
        jOld = str2num(tileFN(4));
        iNew = jOld;
        jNew = jMax-iOld+1; 
        tileFN = ['i' num2str(iNew) 'j' num2str(jNew)];
        MIJ.run('Rotate 90 Degrees Right');
        %%imNew = rot90(im,3);
    case 'Left'
        iOld = str2num(tileFN(2));
        jOld = str2num(tileFN(4));
        jNew = iOld;
        iNew = iMax-jOld+1; 
        tileFN = ['i' num2str(iNew) 'j' num2str(jNew)];
        MIJ.run('Rotate 90 Degrees Left');
        %%imNew = rot90(im);
    case 'Flip'
        iOld = str2num(tileFN(2));
        jOld = str2num(tileFN(4));
        iNew = iOld;
        jNew = jMax-jOld+1; 
        tileFN = ['i' num2str(iNew) 'j' num2str(jNew)];
        MIJ.run('Flip Horizontally');
        %%imNew = fliplr(im);
    otherwise
        %%imNew = im;
    end
    
    % check if tile is all clear, then rename and ignore
    %selectWindow("i1j1.tif");
    %MIJ.run('Histogram');
    %--MIJ.getHistogram();##
    %--MIJ.getStatistics(area, mean)

    tileRoot = [batchNameFull '\' tileFN];
    [pth name] = fileparts(tileRoot); 
    [status, errstr] = mkdir(pth, name);
    if status==0, error(errstr); end;

    imgS = [tileRoot '\' tileFN '.tif'];
    paraS = ['[path=''' imgS ''']'];
    MIJ.run('Save', paraS)
    %%imwrite(imNew,imgS);
    disp(['Tile saved in ' imgS]);
    MIJ.run('Close')   
    hB = waitbar(i/nT, hB, 'Step1 in progress (approx 30min ...)');
end

%% Save 2.5x
    [dn fn ex] = fileparts(imgFN);
    tList = dir([dn '\' fn '_x2.5_z*']); 
    imgS =  [dn '\' tList(1).name]; %[dn '\' fn '_x2.5_z.tif'];
    %figure; imshow(imgS);
%%run("Bio-Formats Windowless Importer", "open=E:\\4all\\_4Aaron\\getRotateInGUI\\69cRotateR_x2.5_z0.tif");
    im = imread(imgS);
    %X = gpuArray(imread(imgS));
    switch rotate_
        case 'Right'
                %MIJ.run('Rotate 90 Degrees Right');
                imNew = rot90(im,3);
        case 'Left'
                %MIJ.run('Rotate 90 Degrees Left');
                imNew = rot90(im);
        case 'Flip'
                %MIJ.run('Flip Horizontally');                
                imNew = fliplr(im);
        otherwise
                imNew = im;
    end    
    %figure; imshow(Y)
    imgS = [dn '\' fn '_x2.5_z0b.tif'];
    imwrite(imNew,imgS);
    disp(['2.5x Image saved in ' imgS]);
%%
toc
%MIJ.exit
% clean batchRoot => delete all jpg and tif
% delete all jpeg and big 20x/40x tif #
delete([batchRoot_ '\' '*_i*.jpg']); 
delete([batchRoot_ '\' '*_x40_*.tif']); 
delete([batchRoot_ '\' '*_x10_*.tif']); 
status = 1;
disp('Step1: Save to TIFF done.');


function [iTiles jTiles] = geIJmax(tList)
for m = 1:length(tList)
    [dn tileName ex ] =  fileparts(tList(m).name);
    s1 = strsplit(tileName, '_');
    v = length(s1);
    %v2 = v1-4;
    s2 = s1(v);
    tileFN = s2{1};
    iTile(m) = str2num(tileFN(2));
    jTile(m) = str2num(tileFN(4));
end

iTiles = max(iTile);
jTiles = max(jTile);
