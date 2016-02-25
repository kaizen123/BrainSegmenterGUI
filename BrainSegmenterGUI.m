function varargout = BrainSegmenterGUI(varargin)
%% BrainSegmenterGUI MATLAB code for BrainSegmenterGUI.fig
% Lilia Mesina, Polaris/CCBN, November2013
% ==
% Last Modified by LM, 15Aug2015

%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BrainSegmenterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BrainSegmenterGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   @BrainSegmenterGUI_Callback);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BrainSegmenterGUI is made visible.
function BrainSegmenterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BrainSegmenterGUI (see VARARGIN)

% Choose default command line output for BrainSegmenterGUI
global homeGUI 
%batchPath batchName nTiles
%global redTresh greenTresh
%global bigWidth bigHeight

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
movegui(hObject,'northwest');

home = pwd;
homeGUI = which('BrainSegmenterGUI');
[homeGUI_ fn ex] = fileparts(homeGUI);
homeGUI = homeGUI_;
addpath(genpath(homeGUI));
fprintf(2, 'BrainSegmenterGUI Path Loaded!');


% --- Outputs from this function are returned to the command line.
function varargout = BrainSegmenterGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%% Set Menu
set_menu(hObject,eventdata,handles);
set(hObject, 'KeyPressFcn',@fKeyPress);


function BrainSegmenterGUI_Callback(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press
function openAnalysis_Callback(hObject, eventdata, handles, sect)
global homeGUI imgFN
global imgName batchRoot batchName 
global iTiles jTiles nTiles
global redTresh greenTresh 
global maxRedTresh maxGreenTresh flipS
global bigWidth bigHeight nCells
global tileWidth tileHeight
global imageAnalysisStatus
global step0 step1 step2 step3 step4 step5
global rotate dataCompute
global verGUI sectName regisRoot
global brainRoot

verGUI = '2.0.4';
if nargin < 4
    [fn, dn, ext] = uigetfile({'*.ndpi';'*.*'},'Select the NDPI Image for Analysis');
else
    dn = batchRoot;
    ndpi_files = dir(fullfile(batchRoot,'*.ndpi'));
    fn = ndpi_files(1).name;
end

hFig2 = findobj('Name','allSectionsView');
close(hFig2);

[fn3 dn3 ex3] = fileparts(fn);
imgName = dn3;

fullFN = fullfile(dn, fn);
if isequal(fn,0)
    disp('User selected Cancel');
    return
else
    disp(['User selected: ' fullFN]);
end

strT = ['BrainSegmenterGUI v' verGUI ' >> %s'];
caption = sprintf(strT, fullFN);
set(gcf, 'Name', caption );
homeGUI = which('BrainSegmenterGUI');
[homeGUI f e] = fileparts(homeGUI);

%% Create a default XML Analysis file
%% init globals
batchRoot = dn;
[dn1 fn1 ext] = fileparts(batchRoot);
[dn1 fn1 ext] = fileparts(dn1);
sectName = fn1;
regisRoot = [dn1 '\ndpi4regis\'];

[dn fn ext] = fileparts(dn1);
brainRoot = dn;

%set brainID
[dn2 fn2 ext] = fileparts(brainRoot);
brainID = fn2;
hObj = findobj('Tag', 'tabBrain');
set(hObj, 'Title', ['Brain: ' brainID]);

hObj = findobj('Tag', 'tabSection');
set(hObj, 'Title', ['Section: ' sectName]);

xmlFile = [batchRoot 'ImageAnalysisProgress.xml'];
if exist(xmlFile, 'file')
    hM = msgbox('Progress XML file exists. Loading analysis...');
    updateControls(xmlFile);
    pause(1);
    close(hM);
else
    copyfile([homeGUI '\lib\ImageAnalysisProgress.xml'], xmlFile);
    dnTmp = batchRoot;
    imgNameTmp = imgName;
    loadProgressFromXML(xmlFile);
    batchRoot = dnTmp;
    imgName = imgNameTmp;
    batchName = ['batch_' imgName];
    para = [];
    para = {{'batchRoot' '' batchRoot}; {'batchName' '' batchName}; {'imgName' '' imgName}};
    saveProgressToXML(para);

    % Check if Step0 is Done
    tList = dir([batchRoot '\*.jpg']); 
    nT = length(tList);
    %nP = length(para);
    if nT
        hObj = findobj('Tag', 'step0');
        set(hObj,'Value', 1);
        step0 = 'Done';
        para = [];
        para{1}  = {'step0' 'Status' 'Done'};
        saveProgressToXML(para);
    end
    
    if exist([batchRoot '\' batchName],'dir')
        strIn = 'i1j1'; %default
        tileFN = [batchRoot '\' batchName '\' strIn '\' strIn '.tif'];
        if ~exist(tileFN,'file')
            tileFN = [batchRoot '\' batchName '\' strIn '_processed\' strIn '_blue_RAW.tif'];
        end
        while ~exist(tileFN,'file')
            x = inputdlg('In the batch folder can''t find tile image (\i1j1\i1j1.tif) to set bigWidth|bigHeight and other parameters. What other tile do you want to use?',...
                 'Input', 1, {'i1j1'});
            strIn = x{:}; 
            tileFN = [batchRoot '\' batchName '\' strIn '\' strIn '.tif'];
        end
        hObj = findobj('Tag', 'step0');
        set(hObj,'Value', 1);
        step0 = 'Done';
        para = [];
        para{1}  = {'step0' 'Status' 'Done'};
        hObj = findobj('Tag', 'step1');
        set(hObj,'Value', 1);
        step1 = 'Done';
        para{2}  = {'step1' 'Status' 'Done'};    
        saveProgressToXML(para);
    if strcmp(imageAnalysisStatus,'None')
        para = [];
        imageAnalysisStatus = 'InProgress';
        para{1} = {'ImageAnalysis' 'Status' imageAnalysisStatus};

        imgInfo = imfinfo(tileFN);
        imgInfo = imgInfo(1);
        tileWidth = imgInfo.Width;
        tileHeight = imgInfo.Height;
        para{2} = {'Tile' 'tileWidth' num2str(tileWidth)};
        para{3} = {'Tile' 'tileHeight' num2str(tileHeight)};

        l = dir([batchRoot '\' batchName '\i*']); 
        nFiles = length(l);
        foundTiles = 0;
        for i =1:nFiles
            l2 = l(i).name;
            if length(l2) ~= 4, continue; end
            foundTiles = 1;            
            a(i,1) = str2num(l2(2)); 
            a(i,2) = str2num(l2(4)); 
        end
        if ~foundTiles  %check processed tiles instead
                l = dir([batchRoot '\' batchName '\i*_processed']); 
                nFiles = length(l);
                for i =1:nFiles
                    l2 = l(i).name;
                    %if length(l2) ~= 4, continue; end
                    a(i,1) = str2num(l2(2)); 
                    a(i,2) = str2num(l2(4)); 
                end
        end
        iTiles = max(a(:,1));
        jTiles = max(a(:,2));
        nTiles = iTiles*jTiles;
        hObj = findobj('Tag','niTiles');
        strVal = num2str(iTiles);
        set(hObj,'String', strVal);
        hObj = findobj('Tag','njTiles');
        strVal = num2str(jTiles);
        set(hObj,'String', strVal);
        hObj = findobj('Tag','nTiles_value');
        strVal = num2str(nTiles);
        set(hObj,'String', strVal);

        para{4} = {'Tiles' 'iTiles' num2str(iTiles)};
        para{5} = {'Tiles' 'jTiles' num2str(jTiles)};
        para{6} = {'Tiles' 'nTiles' num2str(nTiles)};

        bigWidth = jTiles*tileWidth;
        bigHeight = iTiles*tileHeight;
        para{7} = {'Section' 'bigWidth' num2str(bigWidth)};
        para{8} = {'Section' 'bigHeight' num2str(bigHeight)};

        para{9}  = {'step0' 'Status' 'Done'};
        para{10} = {'step1' 'Status' 'Done'};
        hObj = findobj('Tag', 'step0');
        set(hObj,'Value', 1);
        hObj = findobj('Tag', 'step1');
        set(hObj,'Value', 1);
        step0 = 'Done';
        step1 = 'Done';
        strNew = [batchRoot '\' batchName '\'  strIn '_processed\'];
        if exist([strNew strIn '_blue_RAW_BG.tif'],'file')
            step2 = 'Done';
            nP = length(para);
            para{nP+1} = {'step2' 'Status' 'Done'};
            hObj = findobj('Tag', 'step2');
            set(hObj,'Value', 1);
        end
        if exist([strNew 'Results_Image_nuc.tif'],'file')
            step3 = 'Done';
            nP = length(para);
            para{nP+1} = {'step3' 'Status' 'Done'};
            hObj = findobj('Tag', 'step3');
            set(hObj,'Value', 1);
        end
        if exist([strNew 'results_table_raw_edit.txt'],'file')
            step4 = 'Done';
            step5 = 'Done';
            nP = length(para);
            para{nP+1} = {'step4' 'Status' 'Done'};
            para{nP+2} = {'step5' 'Status' 'Done'};
            hObj = findobj('Tag', 'step4');
            set(hObj,'Value', 1);
            hObj = findobj('Tag', 'step5');
            set(hObj,'Value', 1);
        end   
    end
    end
   saveProgressToXML(para);
end
hObj = findobj('Tag', 'redTreshold');
strVal = num2str(redTresh);
set(hObj,'String', strVal);

hObj = findobj('Tag', 'greenTreshold');
strVal = num2str(greenTresh);
set(hObj,'String', strVal);

hObj = findobj('Tag', 'maxRedTresh');
strVal = num2str(maxRedTresh);
set(hObj,'String', strVal);

hObj = findobj('Tag', 'maxGreenTresh');
strVal = num2str(maxGreenTresh);
set(hObj,'String', strVal);

hObj = findobj('Tag', 'flipS');
set(hObj,'Value', flipS);


% --- Executes on button press in runAllSteps.
function runAllSteps_Callback(hObject, eventdata, handles)
% hObject    handle to runAllSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global batchRoot batchName
global step0 step1 step2 step3 step4 step5

xmlFile = [batchRoot 'ImageAnalysisProgress.xml'];    
loadProgressFromXML(xmlFile);
if  isempty(batchRoot)
    set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end
if strcmp(step0,'None')
    %hC = guidata(hObject);
    BrainSegmenterGUI('step0_Callback',hObject,eventdata,guidata(hObject));
    loadProgressFromXML(xmlFile);
    %waitfor(hC);
end
if strcmp(step1,'None')
    BrainSegmenterGUI('step1_Callback',hObject,eventdata,guidata(hObject));
    global imgName batchRoot batchName 
    global iTiles  nTiles
    global redTresh greenTresh 
    global maxRedTresh maxGreenTresh flipS
    global bigWidth bigHeight nCells
    global tileWidth tileHeight
    global imageAnalysisStatus
    global step0 step1 step2 step3 step4 step5
    loadProgressFromXML(xmlFile);
end
if strcmp(step2,'None')
    BrainSegmenterGUI('step2_Callback',hObject,eventdata,guidata(hObject));
    %step3 = 'None'; 
    %try to avoid error "Reference to a cleared variable step3."
        global imgName batchRoot batchName 
        global iTiles jTiles nTiles
        global redTresh greenTresh 
        global maxRedTresh maxGreenTresh flipS
        global bigWidth bigHeight nCells
        global tileWidth tileHeight
        global imageAnalysisStatus
        global step0 step1 step2 step3 step4 step5    
    loadProgressFromXML(xmlFile);
end
if strcmp(step3,'None')
    BrainSegmenterGUI('step3_Callback',hObject,eventdata,guidata(hObject));
    loadProgressFromXML(xmlFile);
end
if strcmp(step4,'None')
    BrainSegmenterGUI('step4_Callback',hObject,eventdata,guidata(hObject));
    loadProgressFromXML(xmlFile);
end
if strcmp(step5,'None')
    BrainSegmenterGUI('step5_Callback',hObject,eventdata,guidata(hObject));
    loadProgressFromXML(xmlFile);
end


function step0_Callback(hObject, eventdata, handles)
%% Split NDPI image in tiles
global imgName batchRoot nTiles step

step = 'Step0'
startTime = datetime
if  isempty(batchRoot)
    set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end
sel = get(hObject,'Value');
if sel
    tic
    hB = waitbar(0, 'Step0 in progress (1-3min) ...');
    %set(hB, 'WindowStyle','modal', 'CloseRequestFcn','');
    %batch.nSlices = 1;
    waitbar(0.3, hB, 'Step0 in progress (1-3min) ...');
    imgFN = [batchRoot imgName '.ndpi'];
    [status nTiles0] = split_ndpi(imgFN);
    %status = 1; nTiles0 = 8; %test
    waitbar(0.8, hB, 'Step0 in progress (1-3min) ...');
    if ~status
        set(hObject,'Enable','on','Value', 0);
        errordlg('Step0: process failed.');
        return
    end
    nTiles = nTiles0;
    valT = num2str(nTiles);
    h = findobj('Tag','nTiles_value');
    set(h,'String',valT);
    waitbar(1, hB, 'Step0 in progress (1-3min) ...');
    close(hB);
    disp('Step0 Done.');    
    saveProgressToXML({{'step0' 'Status' 'Done'}; {'Tiles' 'nTiles' valT}});
    set(hObject,'Value',1);    
    toc
    
    [dn fn ex] = fileparts(imgFN);
    tList = dir([dn '\' fn '_x2.5_z*']); 
    imgS = [dn '\' tList(1).name]; 
    figure; imshow(imgS);
    hM = msgbox('Step0 Done. Select Rotate parameter ...');
    %pause(3); close(hM); %test
end 
saveRunInfo(startTime);



function step1_Callback(hObject, eventdata, handles)
%% Convert tiles to Tif
global imgName batchRoot batchName
global iTiles jTiles nTiles
global tileWidth tileHeight 
global bigWidth bigHeight rotate step

step = 'Step1'
startTime = datetime
if  isempty(batchRoot)
    set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end

sel = get(hObject,'Value');
if sel
    tic
    hB = waitbar(0.1, 'Step1 in progress (approx 30-60min) ...');
    toc
    xmlFile = [batchRoot 'ImageAnalysisProgress.xml'];  
    loadProgressFromXML(xmlFile);    
    batchRoot_ = batchRoot;
    batchName_ = batchName;
    imgFN = [batchRoot imgName '.ndpi'];
    [status iTiles0, jTiles0] = img2tif(imgFN,hB);
    %status = 1; iTiles0 = 1; jTiles0 = 2;
    hB = waitbar(0.9, hB, 'Step1 in progress (approx 30-60min) ...');
    if ~status
        batch.img(1).step1.status = 'Error';
        set(hObject,'Enable','on','Value', 0);
        errordlg('Step1: process failed.');
        return
    end
    loadProgressFromXML(xmlFile);
    iTiles = iTiles0;
    jTiles = jTiles0;
    updatePara;
    set(hObject,'Value',1);    
    hB = waitbar(1, hB, 'Step1 in progress (approx 30-60min) ...');   
    close(hB);
    disp('Step1 Done.');    
    toc
    hM = msgbox('Step1 Done.');
    pause(3);
    close(hM);
end 
saveRunInfo(startTime)


function step2_Callback(hObject, eventdata, handles)
%% Preprocess tiles
global batchRoot batchName homeGUI step

step = 'Step2'
startTime = datetime
if  isempty(batchRoot)
    set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end
sel = get(hObject,'Value');
%test
%bigWidth = 16346*4; %61080; %## get image info just before saving i1j1.tif
%bigHeight = 11114*4; %39888;
if sel
    tic
    hB = waitbar(0, 'Step2 in progress (approx 40min) ...');   
    toc
    %[dn fn ex] = fileparts(imgFN); %test
    str1 = [batchRoot batchName '\']; 
    xmlFN = [batchRoot 'ImageAnalysisProgress.xml'];
    homeGUI = which('BrainSegmenterGUI');
    [homeGUI f e] = fileparts(homeGUI);    
    str2 = [homeGUI '\lib\ProjectDef_seg.xml'];
    tList = dir([str1 'i*']); 
    nFiles = length(tList);

    Miji;
    MIJ.run('Refresh Jython Scripts');
    waitbar(0.1, hB, 'Step2 in progress (approx 40min) ...');   
    %hBar = waitbar(0,'Step2 in Progress ...');
    for i=1:nFiles
        dn = tList(i).name;
        if length(dn)>5, continue; end
        str3 = [str1 dn];
        paraPy = ['choose=' str3 '\ blue=1 red=1 green=1'];
        MIJ.run('Farsight PreProcess', paraPy);
        MIJ.run('Dispose All Windows', '/all non-image');
        %MIJ.run('Select Window', 'Exception');
        %batch() 
        %wait(jobStep2);
        disp([dn ' preprocessed']);
        %waitbar(i/nFiles,hBar);
        
        % LM, 19Aug2015; delete intermediary images to save memory space    
        rmdir(str3,'s')
        %
        
        waitbar(i/nFiles, hB, ['Step2 in progress (approx 40min) ' dn '...']);   
    end
    %MIJ.run('Close All'); % doesn't close Exception window
    %close(hBar);     %close all;
    MIJ.exit;
    
    waitbar(1, hB, 'Step2 in progress (approx 40min) ...');  
    close(hB);
    disp('Step2 Done.');
    loadProgressFromXML(xmlFN);
    saveProgressToXML({{'step2' 'Status' 'Done'}});
    toc
    hObj2 = findobj('Tag', 'step2');    
    set(hObj2,'Value',1); %err deleted obj
    hM = msgbox('Step2 Done.');
    pause(3);
    close(hM);
end
saveRunInfo(startTime)


function step3_Callback(hObject, eventdata, handles)
%% Run FTK cell segmentation on tiles
global batchRoot batchName homeGUI step

step = 'Step3'
startTime = datetime
if  isempty(batchRoot)
    if ~isempty(homeGUI)        
        [batch fileN ext] = fileparts(homeGUI);
    else
        set(hObject,'Value',0);
        errordlg('No Image Analysis Project opened.');
        return
    end
end
sel = get(hObject,'Value');
if sel
    tic
    hB = waitbar(0, 'Step3 in progress (approx 50min) ...');       
    str1 = [batchRoot batchName '\']; 
    xmlFN = [batchRoot '\ImageAnalysisProgress.xml'];
    homeGUI = which('BrainSegmenterGUI');
    [homeGUI f e] = fileparts(homeGUI);
    str2 = [homeGUI '\lib\ProjectDef_seg.xml'];
    strLib3 = [homeGUI '\lib\3rdparty\Farsight0.4.5\bin\'];
    tList = dir([str1 'i*_processed']); 
    nFiles = length(tList);
    waitbar(0.2, hB, 'Step3 in progress (approx 50min) ...');   
    for i=1:nFiles
        fn = tList(i).name;
        dn = [str1 fn '\'];
        listJpg = dir([dn '*_blue_RAW_BG.tif']);
        if ~length(listJpg)
            disp('Tile is clear, skip.');
            continue;
        end
        fnNuc = [dn 'Results_Image_nuc.tif'];
        if exist(fnNuc, 'file')     
            disp('Tile is segmented, skip.');
            continue;
        end
        copyfile(str2, [dn 'ProjectDef_seg.xml']);
        createInputImageXML(dn);
        %addpath(genpath(dn));
        %may need to go from 10 to 12-15 outside cell               
        inParam = [dn 'ProjectDef_seg.xml']; 
        inIDImg = [dn 'Results_Image_nuc.tif'];
        inImg = [dn 'Input_Image.xml'];
        outTable = [dn 'results_table_raw.txt']; %?raw
        [status] = dos(['projproc ' inImg ' ' inIDImg ' ' outTable ' ' inParam], '-echo');
        %save Command Window output to runSegmLog.txt
        %# use try/catch and rename to i1j1c %test
        if status
            h = msgbox(['Folder ' fn '. Segmentation failed, continue.' ]);   
            pause(2);            
            close(h);
            continue
        end
        waitbar(i/nFiles, hB, ['Step3 in progress (approx 50min) ' fn '...']);   
        h = msgbox(['Segmentation done! Folder ' fn]);
        pause(2);            
        close(h);
    end
    disp('Step3 Done.');
    toc
    waitbar(1, hB, 'Step3 in progress (approx 50min) ...');   
    close(hB);
    loadProgressFromXML(xmlFN);
    saveProgressToXML({{'step3' 'Status' 'Done'}});
    set(hObject,'Value',1);
    hB = msgbox('Step3 Done.');
    pause(3);            
    close(hB);
end
saveRunInfo(startTime)


function step4_Callback(hObject, eventdata, handles)
%% Run FTK associative rules for cell classification
global batchRoot batchName nTile
global homeGUI step

step = 'Step4'
startTime = datetime
if  isempty(batchRoot)
    set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end
sel = get(hObject,'Value');
if sel
    tic
    hB = waitbar(0, 'Step4 in progress (approx 30-60min) ...');          
    %[dn fn ex] = fileparts(imgFN);
    str1 = [batchRoot batchName '\']; 
    homeGUI = which('BrainSegmenterGUI');
    [homeGUI f e] = fileparts(homeGUI);
    str2 = [homeGUI '\lib\HistoProjectDef_asso_feat.xml']; 
    strLib3 = [homeGUI '\lib\3rdparty\Farsight0.4.5\bin\'];
    
    tList = dir([str1 'i*_processed']); 
    nFiles = length(tList);
    waitbar(0.2, hB, 'Step4 in progress (approx 30-60min) ...');   
    for i=1:nFiles
        fn = tList(i).name;
        dn = [str1 fn '\'];
        if ~exist([dn 'ProjectDef_seg.xml'],'file')
            h = msgbox(['Skip tile ' dn '. XML definition file absent.']);
            continue;
        end
        disp(['=== Get RAW ASSOCIATIONS in: ' fn]);
        copyfile(str2, [dn 'HistoProjectDef_asso_feat.xml']);
        %may need to go from 10 to 12-15 outside cell            
        inParam = [dn 'HistoProjectDef_asso_feat.xml'];
        inIDImg = [dn 'Results_Image_nuc.tif'];
        inImg = [dn 'Input_Image.xml'];
        outTable = [dn 'results_table_raw.txt'];
        if exist(inImg, 'file') & exist(outTable, 'file')
            [status] = dos(['projproc ' inImg ' ' inIDImg ' ' outTable ' ' inParam], '-echo');
            disp(['=== RAW ASSOCIATIONS done in: ' fn]);
            %save Command Window output to runSegmLog.txt  %test       
        else
            status = 1;
        end
        if status
            h = msgbox(['Folder ' fn '. FTK RAW ASSOCIATIONS failed, continue.']);
            continue
        end
        waitbar(i/nFiles, hB, ['Step4 in progress (approx 30-60min) ' fn '...']);   
        h = msgbox(['FTK RAW ASSOCIATIONS done! Folder ' fn]);
        pause(2);            
        close(h);
    end
    disp('Step4 Done.');
    toc
    waitbar(1, hB, 'Step4 in progress (approx 30-60min) ...');   
    close(hB);
    saveProgressToXML({{'step4' 'Status' 'Done'}});
    set(hObject,'Value',1);
    hM = msgbox('Step4 Done.');
    pause(3);
    close(hM);
end
saveRunInfo(startTime)


function step5_Callback(hObject, eventdata, handles)
%% Compute min/max intensity
% And append as 4 columns to result text file.
global batchRoot batchName nTiles
global redTresh greenTresh step
global maxRedTresh maxGreenTresh flipS

step = 'Step5'
startTime = datetime
if  isempty(batchRoot)
    set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end
disp(['redTresh: '   num2str(redTresh)]);
disp(['greenTresh: ' num2str(greenTresh)]);
disp(['maxRedTresh: ' num2str(maxRedTresh)]);
disp(['maxGreenTresh: ' num2str(maxGreenTresh)]);
sel = get(hObject,'Value');
if sel
    tic
    hB = waitbar(0, 'Step5 in progress (approx 15-20min) ...');         
%% Load ij tile objects
    batchFullName = [batchRoot batchName];
    dirList = dir(batchFullName);
    j1 = 0;
    xy = cell(nTiles,1);
    waitbar(0.2, hB, 'Step5 in progress (approx 15-20min) ...');       
    nFiles = length(dirList);
    for i1 = 1:nFiles
        %dirList = FindFiles('*_processed','',dn3);
        processedF = dirList(i1).name;
        %disp(processedF); %test
        if ~isempty(strfind(processedF,'_processed'))
         fn = [batchFullName '\' processedF '\results_table_raw.txt'];
         if exist(fn, 'file')
             %disp(fn); %test
             found = 1;
             j1 = j1 +1;
             %disp(processedF(2)); %test

             xyTemp = importdata(fn); %use textscan() for Ascii
             iTile = str2num(processedF(2));
             jTile = str2num(processedF(4));
             k = jTile + 4*(iTile-1);
             
             disp(['===== Loading tile:  i' num2str(iTile) 'j' num2str(jTile) 'k' num2str(k)]);
             xy{k}.data = xyTemp.data(:,1:3);
             xy{k}.iTile = iTile;
             xy{k}.jTile = jTile;
             dnImg = [batchFullName '\' processedF '\'];
             fnImg = dir([dnImg '*blue*_RAW.tif']);
             if exist([dnImg fnImg.name], 'file')
                imgInfo = imfinfo([dnImg fnImg.name]);
                imgInfo = imgInfo(1);
                xy{k}.width = imgInfo.Width;
                xy{k}.height = imgInfo.Height;
             else
                 disp(['Can''t open RAW blue channel to get image info. Continue.']);
             end
             %% Check if exists red_TOTAL column, then treshold data
             findRed = strfind(xyTemp.colheaders,'red_TOTAL');
             xy{k}.tracerRed = [];
             col = find(~cellfun(@isempty,findRed));
             if ~isempty(col)
                tempM = xyTemp.data(:,col); %34);
                tempM(tempM < redTresh)=0;
                xy{k}.tracerRed = tempM;
                
                disp('=== Compute min/max Red:');
                imnuc = [dnImg 'Results_Image_nuc.tif'];
                img = dir([dnImg '*red*_RAW.tif']); %on RAW
                img = [dnImg img(1).name];
                ids = xyTemp.data(:,1);     
                tracer = xy{k}.tracerRed(:);
                nIDs = length(ids);
                fprintf('The tile has a total of %d cells \n',nIDs);
                nTr = find(tracer);
                nTr = length(nTr);
                if nTr
                    fprintf('There are only %d cells with red tracer \n',nTr);
                    minRed = []; maxRed = [];
                    [minRed maxRed] = getMinMaxIntensity(imnuc, img, ids, tracer)
                    xy{k}.minRed = minRed;
                    xy{k}.maxRed = maxRed;
                else
                    fprintf('There are no cells with red tracer. Skip. \n');
                    xy{k}.minRed = zeros(nIDs,1); xy{k}.maxRed = zeros(nIDs,1);
                end
             end
             %% Check if exists green_TOTAL, then treshold data
             findGreen = strfind(xyTemp.colheaders,'green_TOTAL');
             xy{k}.tracerGreen = [];
             col = find(~cellfun(@isempty,findGreen));
             if ~isempty(col)
                 tempM = xyTemp.data(:,col); %35);
                 tempM(tempM < greenTresh)=0;                 
                 xy{k}.tracerGreen = tempM;
                
                disp('=== Compute min/max Green:');
                imnuc = [dnImg 'Results_Image_nuc.tif'];
                img = dir([dnImg '*green*_RAW.tif']); %on RAW !
                img = [dnImg img(1).name];
                ids = xyTemp.data(:,1);     
                tracer = xy{k}.tracerGreen(:);
                nIDs = length(ids);
                fprintf('The tile has a total of %d cells \n',nIDs);
                nTr = find(tracer);
                nTr = length(nTr);
                if nTr
                    fprintf('There are only %d cells with green tracer \n',nTr);
                    minGreen = []; maxGreen = [];
                    [minGreen maxGreen] = getMinMaxIntensity(imnuc, img, ids, tracer)
                    xy{k}.minGreen = minGreen; xy{k}.maxGreen = maxGreen;
                else
                    fprintf('There are no cells with green tracer. Skip. \n');
                    xy{k}.minGreen = zeros(nIDs,1); xy{k}.maxGreen = zeros(nIDs,1);
                end
             end 
             %% Min/Max column append
%test
%{             
%              if ~isempty(xy{k}.minRed)
%                  colNames = {'minRed' 'maxRed'};
%                  colData = [xy{k}.minRed xy{k}.maxRed];
%                  farsight_results_append(fn,colNames,colData);
%              end
%              if ~isempty(xy{k}.minGreen)
%                  colNames = { 'minGreen' 'maxGreen'};             
%                  colData = [xy{k}.minGreen xy{k}.maxGreen];
%                  farsight_results_append(fn,colNames,colData);
%              end
%}
             colNames = {'minRed' 'maxRed' 'minGreen' 'maxGreen'};             
             colData = [xy{k}.minRed xy{k}.maxRed xy{k}.minGreen xy{k}.maxGreen];
             farsight_results_append(fn,colNames,colData);
             
         else
            disp(['File ' processedF ' doesn''t exist. Continue.']);
         end
        end
        waitbar(i1/nFiles, hB, ['Step5 in progress (approx 15-20min) ' processedF '...']);       
    end
    if j1 == 0
        errordlg(['Could not find processed tiles in directory ' batchFullName],'File Error');
        return;
    end;   
    %% step done
    xyTemp = []; xBig = []; yBig = []; cBig = []; %xy{nTiles} = [];  
    disp('Step5 Done.');
    toc
    waitbar(1, hB, 'Step5 in progress (approx 15-20min) ...');   
    close(hB);
    saveProgressToXML({{'step5' 'Status' 'Done'}});
    set(hObject,'Value',1);
    hM = msgbox('Step5 Done.');
    pause(3);
    close(hM);
end
saveRunInfo(startTime)


function step6_Callback(hObject, eventdata, handles)
%% Load Image Analysis Results
global batchRoot batchName nTiles
global redTresh greenTresh refROI
global maxRedTresh maxGreenTresh flipS
global xBig yBig cBig nCells step3
global bigWidth bigHeight
global regisRoot sectName flipS

if  isempty(batchRoot)
    set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end
if ~redTresh
    msgbox('Step6: No Red Treshold defined. Error.');
end
%if ~redTresh

sel = get(hObject,'Value');
if sel
    roi40 = [];
    if strcmp(step3,'None')
        set(hObject,'Value',0);
        errordlg('Step3 not completed.');
        return
    end
    %% if needed, create folders for regitration files
    [dn fn ex] = fileparts(batchRoot);
    [dn fn ex] = fileparts(dn);
    dnBFI = [dn '\bfi4regis']
    if ~exist(dnBFI, 'dir')
        mkdir(dn,'bfi4regis');
    end
    dnRegis = [dn '\ndpi4regis']
    if ~exist(dnRegis, 'dir')
        mkdir(dn,'ndpi4regis');
    end
    dnSection = [dnRegis '\' sectName]
    if ~exist(dnSection, 'dir')
        mkdir(dnRegis,sectName);
    end   
    
    %% Load ij tile objects
    batchFullName = [batchRoot batchName];
    dirList = dir([batchFullName '\i*_processed']);
    %nTiles, get from xml
    nTiles = length(dirList);
    j1 = 0; k=0;
    xy = cell(nTiles,1);
    hB = waitbar(0, 'Step6 in progress, loading tiles...');   
    for i1 = 1:nTiles
         %dirList = FindFiles('*_processed','',dn3);
         processedF = dirList(i1).name;
         %disp(processedF); %if ~isempty(strfind(processedF,'_processed')) %test
         fileFound = 0;
         dnTile = [batchFullName '\' processedF]; 
         fn = [dnTile '\results_table_raw_edit.txt'];
         if ~exist(fn, 'file')
             fn = [dnTile '\results_table_raw.txt'];
             if ~exist(fn, 'file')
                 disp(['No results*.txt file in folder ' ...
                       dnTile ', need to run Step4/5. Skip.']);
                 fileFound = 0;
                 continue;
             else
                 fileFound = 1;     
             end
         else
             fileFound = 1;
         end
             if ~fileFound, continue; end
             found = 1;
             %disp(fn); %j1 = j1 +1; %disp(processedF(2)); %test
             xyTemp = importdata(fn); 
             iTile = str2num(processedF(2));
             jTile = str2num(processedF(4));
             k = k+1; %jTile + 2*(iTile-1); %iMax
             disp(['Loading tile:  i' num2str(iTile) 'j' num2str(jTile) 'k' num2str(k)]);
             xy{k}.data = xyTemp.data(:,1:3);
             xy{k}.iTile = iTile;
             xy{k}.jTile = jTile;
             
             %% init Tracer r/g info
             findRed = strfind(xyTemp.colheaders,'red_TOTAL');
             xy{k}.tracerRed = [];
             if ~isempty(findRed)
                col = find(~cellfun(@isempty,findRed));
                tempM = xyTemp.data(:,col); %34); %test
                tempM(tempM < redTresh)=0;
                xy{k}.tracerRed = tempM;
             end
             findGreen = strfind(xyTemp.colheaders,'green_TOTAL');
             xy{k}.tracerGreen = [];
             if ~isempty(findGreen)
                col = find(~cellfun(@isempty,findGreen));
                tempM = xyTemp.data(:,col); %34); %test
                tempM(tempM < greenTresh)=0;
                xy{k}.tracerGreen = tempM;
             end

             findTracer = strfind(xyTemp.colheaders,'minRed');
             xy{k}.tracerMinMax = [];
             col = find(~cellfun(@isempty,findTracer));
             if ~isempty(col)
                colLast = col+3;
                tempM = xyTemp.data(:,col:colLast); %4 columns
                xy{k}.tracerMinMax = tempM;
%              else
%                  errordlg(['Min/Max tracer info not found for tile i' num2str(iTile) 'j' num2str(jTile)  ', might need to run Step5. Skip.']);
%                  return
             end
             dnImg = [batchFullName '\' processedF '\'];
             fnImg = dir([dnImg '*blue*_RAW.tif']);
             if exist([dnImg fnImg.name], 'file')
                imgInfo = imfinfo([dnImg fnImg.name]);
                imgInfo = imgInfo(1);
                xy{k}.width = imgInfo.Width;
                xy{k}.height = imgInfo.Height;
             else
                 disp('Can''t open RAW blue channel to get image info. Continue.');
             end
             waitbar(i1/nTiles, hB, 'Step6 in progress, loading tiles...');   
    end
    
    %% Compute tile information and offset to get the big image points/dots
    disp('======= Combine all tiles into one big figure:');
    width = xy{1}.width;
    height = xy{1}.height;
    xPlot = []; yPlot = []; cPlot = [];
    xBig = []; yBig = []; cBig = [];
    tileTracerInfo = []; tracerInfo = [];
    waitbar(0, hB, 'Step6 in progress, processing tiles...');   
    for i = 1:nTiles
             if isempty(xy{i}), continue; end
             iTile = xy{i}.iTile;
             jTile = xy{i}.jTile;
             offsetX = (iTile-1) * height; %test 9972; %15270;
             offsetY = (jTile-1) * width; %test 15270; %9972;
             disp(['processing i' num2str(iTile) 'j' num2str(jTile) ...
                 ', offX=' num2str(offsetX/(iTile-1)) ...
                 ', offY=' num2str(offsetY/(jTile-1))]);
             %k = jTile + 4*(iTile-1); %test
             xPlot = xy{i}.data(:,2);
             xPlot = xPlot + offsetY;
             yPlot = xy{i}.data(:,3);%test abs(.. -15270); %*offsetY; axis ij
             yPlot = yPlot + offsetX;
             cPlot = zeros(length(xPlot),3); 
             
             %% Set all points by default to blue color [0 0 1]
             cPlot(:,1) = 0; cPlot(:,2) = 0; cPlot(:,3) = 1; 
             n2 = length(xPlot);
                          
            %% Set red color [r 0 0]        
            % green last, because red+ can show green+ also
            if ~isempty(xy{i}.tracerMinMax) 
                for k1 = 1:n2
                    if (xy{i}.tracerMinMax(k1,2) >= maxRedTresh)
%                         t1 = logical(xy{i}.tracerGreen(i2));
%                         t2 = logical(xy{i}.tracerRed(i2));
%                         if ~t1 & t2;
                        if cPlot(k1,2) %for test only
                            %disp();
                            errordlg(['Cell b' num2str(i) 'k' num2str(k1) ' double marked: Green and now Red. Test...']); 
                        end
                            cPlot(k1,1) = 1; %xy{i}.tracerRed(i2);
                            cPlot(k1,2) = 0; 
                            cPlot(k1,3) = 0; 
                        %end
                    end
                end
             end
             %% Set green (yellow) color [0 g 0]
             if  ~isempty(xy{i}.tracerMinMax) %test ~isempty(xy{i}.tracerGreen) &&
                 for k1 = 1:n2
                     if xy{i}.tracerMinMax(k1,4) >= maxGreenTresh
                        % if xy{i}.tracerGreen(k1)
                        if cPlot(k1,1) %for test only
                            %disp();
                            disp(['Cell b' num2str(i) 'k' num2str(k1) ' double marked: Red and now Green. Test...']); 
                        end
                            cPlot(k1,1) = 0; 
                            cPlot(k1,2) = 1; %xy{i}.tracerGreen(i2); % $set to Green or normalize
                            cPlot(k1,3) = 0; 
                        % end
                     end
                 end
            end
             %segX = offsetX+1:offsetX+9972+1;
             %segY = offsetY+1:offsetY+15270+1;
             xBig = [xBig; xPlot];
             yBig = [yBig; yPlot]; % offsetX+1];
             cBig = [cBig; cPlot];
             tileTracerInfo = [xy{i}.tracerRed, xy{i}.tracerGreen, xy{i}.tracerMinMax];
             tracerInfo = [tracerInfo; tileTracerInfo];
             waitbar(i/nTiles, hB, 'Step6 in progress, processing tiles...');   
    end
    xPlot = []; yPlot = []; cPlot = []; tileTracerInfo = [];  %###
    %{
    %normalize tracer #
    minRed = getMin(cBig(:,1)); %get min, but ignore 0
    maxRed = max(cBig(:,1));
    minGreen = getMin(cBig(:,2));
    maxGreen = max(cBig(:,2));
    cBigN(:,1) = mat2gray(cBig(:,1), [minRed maxRed]); 
    cBigN(:,2) = mat2gray(cBig(:,2), [minGreen maxGreen]); 
    cBigN(:,3) = cBig(:,3);
    %}
    %% plot ROI if defined
    if isempty(sectName)
        [dn fn] = fileparts(batchRoot);
        [dn fn] = fileparts(dn);
        sectName = fn;
    end
    csvFN = [batchRoot sectName '_40xROI.txt'];
    if exist(csvFN,'file')
        [roi40] = importdata(csvFN);
        xv = roi40(:,1);
        yv = roi40(:,2);
%        redX = xBig(cBig(:,1)>0);
%        redY = yBig(cBig(:,1)>0);
        inP = inpolygon(xBig,yBig,xv,yv);
        redNotIn = find(cBig(:,1)>0 & inP<1);
        n40 = length(redNotIn);
        for i = 1:n40
%             cBig(xBig(~inP),1) = 0;
%             cBig(xBig(~inP),3) = 1;
            k = redNotIn(i);
            cBig(k,1) = 0;
            cBig(k,3) = 1;
        end
    end 
    
    %% Save allData to mat file, LM, 13Dec2013
    allData = [xBig, yBig, cBig, tracerInfo]; %5+6 columns
    allData = uint32(allData);
    fn = [batchRoot 'allData.mat'];
    save(fn, 'allData');
    disp(['===== All data saved to file ' fn]);
    waitbar(1, hB, 'Step6 in progress, processing tiles...');   
    close(hB);
    

    %% Plot big image
    disp('===== Plot the big image');
    %plot whole slice
    hFig = figure('Tag', 'bigPlot', 'Name', ['Slice Plot ' batchRoot]);   
    
    hObj = findobj('Tag','nTiles_value');
    strVal = num2str(nTiles);
    set(hObj,'String', strVal);
    hObj = findobj('Tag','allCellsV');
    nCells = length(xBig);
    strVal = num2str(nCells);
    set(hObj,'String', strVal);
    saveProgressToXML({{'Section' 'nCells' num2str(nCells)}});
    h = plot(xBig,yBig,'.','Color', 'b','MarkerSize', 1);
    
    %test
    %--h = plot(xBig,yBig,'.','Color', [cBig(49,1) cBig(49,2) cBig(49,3)],'MarkerSize', 1);
    % h = scatter(xBig,yBig,2,cBig); %,'.','Color', [cBig(49,1) cBig(49,2) cBig(49,3)],'MarkerSize', 1); ?use plot for Blue and scatter for others???

    set(gca, 'Color', 'k');
    %test axis([0 9972 0 15270]);
    axis image; axis tight;
    axis ij
    
    if ~isempty(roi40)
        hold on
        plot(roi40(:,1), roi40(:,2), 'w-');
    end
    
    hObj = findobj('Tag','allRedV');
    allRed = sum(cBig(:,1));   
    strVal = num2str(allRed);
    set(hObj,'String', strVal);  
    hObj = findobj('Tag','allGreenV');
    allGreen = sum(cBig(:,2));   
    strVal = num2str(allGreen);
    set(hObj,'String', strVal);  
    
    hObj = findobj('Tag','redTracer');
    set(hObj,'Value',1);
    BrainSegmenterGUI('redTracer_Callback',hObject,eventdata,guidata(hObject));
    
    %% Save tracer points to csv
    % Get points to save to csv file for registration
    % check below section
    redX = xBig(cBig(:,1)>0);
    redY = yBig(cBig(:,1)>0);
%     flipPoints = 1;  % manual for now, to test flip on points
%     if flipPoints
%         redXflip = (bigWidth+1)-redX;
%         redX = redXflip;
%     end
    
    tmp = [redX redY];
        
    x40 = padarray(tmp,[0 1],'post');
    x40int = uint16(x40);    
%     %x40 = ['x' 'y' 'z'; x40];
%     csvFN = [batchRoot 'xyz40xRed.csv'];
%     csvwrite(csvFN,x40int);
%     disp(['40x image size in pixels: ' num2str(bigWidth) 'x' num2str(bigHeight)]);    
    
    dnImg = batchRoot;
    fnImg = dir([dnImg '*z0b.tif']);
    if exist([dnImg fnImg.name], 'file')
        img_z0b = [dnImg fnImg.name]; %&4test
        imgInfo = imfinfo(img_z0b);
        imgInfo = imgInfo(1);
        x2p5Width = imgInfo.Width;
        x2p5Height = imgInfo.Height;
        csvFN0 = [regisRoot sectName];
        if ~exist([csvFN0 '\In\'], 'dir')
                mkdir(csvFN0,'In');
        end
        csvFN1 = [csvFN0 '\In\' sectName];
        
        disp(['2.5x_b image size in pixels: ' num2str(x2p5Width) 'x' num2str(x2p5Height)]);
        xDiv = bigWidth/x2p5Width;
        yDiv = bigHeight/x2p5Height;
        x2p5(:,1) = x40(:,1)./xDiv; %15.85;  % just /15 gives displacement
        x2p5(:,2) = x40(:,2)./yDiv; %15.99;
       
        x2p5int = uint16(x2p5);    
        x2p5int2 = applyOffset(x2p5int);
        savePoints2csv(csvFN1,x2p5int2,x2p5Width);
        
        %% test offset
        %{ 4test
        % save a copy of the Big Figure
        set(gcf, 'InvertHardCopy', 'off');
        print(hFig, '-dpng', '-r600', [csvFN1 '_bigPlotFigure.png']);

        T1 = readtable([csvFN1 '_xy2p5xRedIn.csv']);
        T2 = readtable([csvFN1 '_xy2p5xRed_mmIn.csv']);
        img2p5B = [csvFN1 '_x2.5B.tif'];
        img2p5B_ = imread(img2p5B);
        img2p5z0b = img_z0b;
        img2p5z0b_ = imread(img2p5B);
        hFtest = figure();
        hold on
        C = imfuse(img2p5z0b_,img2p5B_,'falsecolor','Scaling','joint'); %,'ColorChannels',[1 2 0]);
        imshow(C); 
        title(['In points on ' img2p5B]);
        hold on
        xIn2p5 = T1.x;%/0.0036; %1); #2.5x space
        yIn2p5 = T1.y;%/0.0036; %(:,2);
        plot(xIn2p5,yIn2p5,'o','Color', 'r','MarkerSize', 5);
        hold on
        xIn2p5mm = T2.x/0.0036; %1); #2.5x space
        yIn2p5mm = T2.y/0.0036; %(:,2);
        plot(xIn2p5mm,yIn2p5mm,'*','Color', 'y','MarkerSize', 5);
        print(hFtest, '-dpng', '-r600', [csvFN1 '_InPointsOnBlueChannel.png']);  
        close(hFtest);
    else
         disp('Can''t find 2.5x image to get image info. Skip csv.');
    end
end


function step7_Callback(hObject, eventdata, handles)
%% Load Reference Lines
global batchRoot refLine_R refLine_L
global refROI_L refROI_R in_R in_L xBig yBig
global refPoints_R refPoints_L
global dataCompute
global bigWidth bigHeight
global allRefs

if  isempty(batchRoot)
    %set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end

sel = get(hObject,'Value');
if sel
    str1 = [batchRoot 'line\'];
    if ~isdir(str1)
        set(hObject,'Value',0);
        errordlg(['No Reference lines folder exists in ' batchRoot]);
        %close(hB);
        return
    end    
    fList = dir([str1 '*_new.txt']); 
    nFiles = length(fList);
    if ~nFiles
        BrainSegmenterGUI('scaleLines_Callback',hObject,eventdata,guidata(hObject));
    end
    hB = waitbar(0, 'Load RefLines in progress (1-3min) ...');
    waitbar(0.1, hB, 'Load RefLines in progress (1-3min) ...');
    
    %% Load ROIs
    %str1 = [batchRoot 'line\']; %test
    fList = dir([str1 '*Sout_new.txt']); 
    nFiles = length(fList);
    if ~nFiles
       errordlg('For *Sout_new.txt No files found.');
       return
    elseif nFiles > 2 
       errordlg('For *Sout_new.txt more than 2 files found.');
       return
    end
    for i = 1:nFiles
        fullFN = [str1 fList(i).name];
        disp(fullFN);
        [refROI0] = importdata(fullFN);
        refROI = refROI0;
        xv = refROI(:,1);
        yv = refROI(:,2);
        in = inpolygon(xBig,yBig,xv,yv);
        hFig = findobj('Tag', 'bigPlot');
        %axes(handles.axes1);
        if isempty(hFig)
              errordlg('Big Plot figure not found');
              return
        end
        figure(hFig); 
        hold on
        %plot(xv,yv,'w-',xBig(in),yBig(in),'b.',xBig(~in),yBig(~in),'c.','MarkerSize', 1); %test
        plot(xv,yv,'w-'); %,xBig(in),yBig(in),'b.',xBig(~in),yBig(~in),'c.','MarkerSize', 1);
        figure(hFig); 
        if ~isempty(strfind(fullFN,'LSout_new'))
            refROI_L = refROI;
            in_L = in;
        elseif ~isempty(strfind(fullFN,'RSout_new'))
            refROI_R = refROI;
            in_R = in;
        else
            errordlg('Can''t decide on L/R refROI.');
            return
        end
    end
    waitbar(0.4, hB, 'Load RefLines in progress (1-3min) ...');
   
    xmlFile = [batchRoot 'ImageAnalysisProgress.xml'];      
    loadProgressFromXML(xmlFile);
    if strcmp(dataCompute,'ROI')
%         dispInROIcells('Green','L');
%         dispInROIcells('Green','R');
%         dispInROIcells('Red','L');
%         dispInROIcells('Red','R');
        disp('ROI mode on.');
        close(hB);        
        return
    end
    
    %% Load reference lines from text file    
    fList = dir([str1 '*S_new.txt']); 
    nFiles = length(fList);
    if ~nFiles
       errordlg('For *S_new.txt No files found.');
       return
    elseif nFiles > 2 
       errordlg('For *S_new.txt more than 2 files found.');
       return
    end
    for i = 1:nFiles
        fullFN = [str1 fList(i).name];
        disp(fullFN);
        [refLine] = importdata(fullFN);
        %refLineS = scaleLines(fullFN);
        
        %disp line in axes 
        hFig = findobj('Tag', 'bigPlot');
        if isempty(hFig)
              errordlg('Big Plot figure not found');
              return
        end   
        figure(hFig); 
        hold on
        plot(refLine(:,1),refLine(:,2),'y-');
        if ~isempty(strfind(fullFN,'LS_new'))
            refLine_L = refLine;
        elseif ~isempty(strfind(fullFN,'RS_new'))
            refLine_R = refLine;
        else
            errordlg('Can''t decide on L/Rs_new (refLine).');
            return
        end
    end
    waitbar(0.8, hB, 'Load RefLines in progress (1-3min) ...');
    
    %% Load reference points: refPoints_R refPoints_L
    fList = dir([str1 '*retro*_new.txt']); 
    nFiles = length(fList);
    if ~nFiles
       errordlg('For *retro*_new.txt No files found.');
       return
    elseif nFiles > 2 
       errordlg('For *retro*_new.txt more than 2 files found.');
       return
    end
    for i = 1:nFiles
        fullFN = [str1 fList(i).name];
        disp(fullFN);
        [refLine] = importdata(fullFN);
        hFig = findobj('Tag', 'bigPlot');
        if isempty(hFig)
              errordlg('Big Plot figure not found');
              return
        end   
        figure(hFig); 
        hold on
        plot(refLine(:,1),refLine(:,2),'y-');
        hold on
        if ~isempty(strfind(fullFN,'retroL_new'))
            x1 = refLine(:,1)';
            y1 = refLine(:,2)';
            x2 = refLine_L(:,1)';
            y2 = refLine_L(:,2)';
            P = InterX([x1;y1],[x2;y2]);
            refPoints_L = P';
            plot(refPoints_L(1,1),refPoints_L(1,2),'ro');
        elseif ~isempty(strfind(fullFN,'retroR_new'))
            x1 = refLine(:,1)';
            y1 = refLine(:,2)';
            x2 = refLine_R(:,1)';
            y2 = refLine_R(:,2)';
            P = InterX([x1;y1],[x2;y2]);
            refPoints_R = P';
            plot(refPoints_R(1,1),refPoints_R(1,2),'ro');
        else
            errordlg('Can''t decide on L/Rs_new (refLine).');
            return
        end
    end
    waitbar(0.9, hB, 'Load RefLines in progress (1-3min) ...');
    
    %% Append PRh_R PRh_L refPoints_R refPoints_L
    fList = dir([str1 '*PRh_*_new.txt']); 
    nFiles = length(fList);
    if ~nFiles
       errordlg('For *PRh_*_new.txt No files found.');
       return
    elseif nFiles > 2 
       errordlg('For *PRh_*_new.txt more than 2 files found.');
       return
    end
    for i = 1:nFiles
        fullFN = [str1 fList(i).name];
        disp(fullFN);
        [refLine] = importdata(fullFN);
        hFig = findobj('Tag', 'bigPlot');
        if isempty(hFig)
              errordlg('Big Plot figure not found');
              return
        end   
        figure(hFig); 
        hold on
        plot(refLine(:,1),refLine(:,2),'r-');
        hold on
        if ~isempty(strfind(fullFN,'PRh_L_new'))
            x1 = refLine(:,1)';
            y1 = refLine(:,2)';
            x2 = refLine_L(:,1)';  
            y2 = refLine_L(:,2)';
            P = InterX([x1;y1],[x2;y2]);
            refPoints_L = [refPoints_L; P(1) P(2)];
            plot(P(1),P(2),'gX');
        elseif ~isempty(strfind(fullFN,'PRh_R_new'))
            x1 = refLine(:,1)';
            y1 = refLine(:,2)';
            x2 = refLine_R(:,1)';
            y2 = refLine_R(:,2)';
            P = InterX([x1;y1],[x2;y2]);
            refPoints_R = [refPoints_R; P(1) P(2)];
            plot(P(1),P(2),'gX');
        else
            errordlg('Can''t decide on L/R.');
            return
        end
    end
    if ~exist([batchRoot 'analysis2'], 'dir')
        mkdir(batchRoot,'analysis2');
    end
    set(gcf, 'InvertHardCopy', 'off');
    print(hFig, '-dpng', '-r600', [batchRoot 'analysis2\bigPlotFigure.png']);
    %saveas(hFig,[batchRoot 'analysis\bigPlotFigure.png']);
    set(hObject,'Value',1);
    waitbar(1, hB, 'Load RefLines in progress (1-3min) ...');
    close(hB);
%% Load V1 refs
allRefs = [];
loadRefs('V1','a','L');
loadRefs('V1','b','L');
loadRefs('V1','a','R');
loadRefs('V1','b','R');
%plotRefs('V1','L');
end


function step8_Callback(hObject, eventdata, handles)
%% Compute Tracer Results
global refROI_L refROI_R refLine_L refLine_R refPoints_L refPoints_R
global xBig yBig cBig in_L in_R
global batchRoot step4 step5 
global dataCompute flipS

sel = get(hObject,'Value');
if sel
    xmlFile = [batchRoot 'ImageAnalysisProgress.xml'];    
    loadProgressFromXML(xmlFile);
    if strcmp(step4,'None') || strcmp(step5,'None')
        set(hObject,'Value',0);
        errordlg('Step4 or Step5 not completed.');
        return
    end
    
    hFig = findobj('Tag', 'bigPlot');
    if isempty(hFig)
          errordlg('Big Plot figure not found');
          return
    end
    
    hObjInROI = findobj('Tag','cellsInROI');
    set(hObjInROI,'String', '');   
    hObj = findobj('Tag','redInROI');
    set(hObj,'String', ''); 
    hObj = findobj('Tag','greenInROI');
    set(hObj,'String', ''); 

    figure(hFig); hold on
    %hB = waitbar(0.1, 'Compute Map (approx 5min) ...');       
    if strcmp(dataCompute,'Distance')      
            %% get mean refPoint_L from refLine_L
%             nM = length(refLine_L); use refPoints_L intead
%             xM = [refLine_L(1,1), refLine_L(nM,1)];
%             yM = [refLine_L(1,2), refLine_L(nM,2)];
        if isempty(refPoints_L)
          errordlg('No RefPoints set, need to run Load Reference Lines.');
          return
        end
            xM = refPoints_L(1:2,1);
            yM = refPoints_L(1:2,2);
            refPoint_L = [mean(xM), mean(yM)]; 
            plot(refPoint_L(1), refPoint_L(2), 'y*', 'MarkerSize', 8);
            %% get mean refPoint_R from refLine_R
%             nM = length(refLine_R);
%             xM = [refLine_R(1,1), refLine_R(nM,1)];
%             yM = [refLine_R(1,2), refLine_R(nM,2)];
            xM = refPoints_R(1:2,1);
            yM = refPoints_R(1:2,2);
            refPoint_R = [mean(xM), mean(yM)];
            plot(refPoint_R(1), refPoint_R(2), 'y*', 'MarkerSize', 8);
    end
    %% Select in_L with Red Tracer
    xTemp = xBig(in_L);
    yTemp = yBig(in_L);
    n1 = length(xTemp);
    %strInROI = get(hObjInROI,'String');   
    strInROI = ['L' num2str(n1)];
    set(hObjInROI,'String', strInROI);   
    
    k = 0; dat = [];   
    for i = 1:n1
        [i_2] = getInd(xTemp(i), yTemp(i));
        %if ~in_L(i), continue; end
        if cBig(i_2,1) %red
            k = k + 1;
            dat(k,1) = xTemp(i);
            dat(k,2) = yTemp(i);
            if strcmp(dataCompute,'ROI'), continue; end;
            %plot(dat(k,1),dat(k,2),'w+','MarkerSize', 6); %test
            [xyLine,dist,t_a] = distance2curve(refLine_L,[xTemp(i) yTemp(i)],'linear');
            %[xy,distance,t_a] = distance2curve(curvexy,mapxy,'linear');
            %var1 = sprintf('%.2f',distance); %in pixels            
            [xyLine1,dist1,t_a1] = distance2curve(xyLine,refPoint_L,'linear');
            [xyLine2,dist2,t_a2] = distance2curve(refPoint_L,[xTemp(i) yTemp(i)],'linear');
            if dist1 >= dist2
                     dat(k,3) = (-1)*dist;
                     line([xTemp(i), xyLine(1)],[yTemp(i), xyLine(2)],'LineWidth',1,'Color','r');
            else
                     dat(k,3) = dist;
                     line([xTemp(i), xyLine(1)],[yTemp(i), xyLine(2)],'LineWidth',1,'Color','m');
            end
            %disp(['dist1 ' num2str(dist1) '; dist2 ' num2str(dist2) '; distLast ' num2str(dist)]); %test
            dat(k,4) = xyLine(1);
            dat(k,5) = xyLine(2);
        end
    end
    datN = length(dat);
    dat = int32(dat);
    dispInROIcells('Red','L',datN)
    saveData('Red','L',dat);
    distOfRed_InLeft = dat;
    
    %% Select in_L with Green Tracer
    k = 0; dat = [];   
    for i = 1:n1
        [i_2] = getInd(xTemp(i), yTemp(i));
        if cBig(i_2,2) %green
            k = k + 1;
            dat(k,1) = xTemp(i);
            dat(k,2) = yTemp(i);
            if strcmp(dataCompute,'ROI'), continue; end;
            %plot(dat(k,1),dat(k,2),'w+','MarkerSize', 6); %test            
            [xyLine,dist,t_a] = distance2curve(refLine_L,[xTemp(i) yTemp(i)],'linear');
            %[xy,distance,t_a] = distance2curve(curvexy,mapxy,'linear');
            %var1 = sprintf('%.2f',distance); %in pixels
            [xyLine1,dist1,t_a1] = distance2curve(xyLine,refPoint_L,'linear');
            [xyLine2,dist2,t_a2] = distance2curve(refPoint_L,[xTemp(i) yTemp(i)],'linear');
            %disp(['dist1 ' num2str(dist1) '; dist2 ' num2str(dist2)]);
            if dist1 >= dist2
                     dat(k,3) = (-1)*dist;
                     line([xTemp(i), xyLine(1)],[yTemp(i), xyLine(2)],'LineWidth',1,'Color','c');
            else
                     dat(k,3) = dist;
                     line([xTemp(i), xyLine(1)],[yTemp(i), xyLine(2)],'LineWidth',1,'Color','g');
            end
            dat(k,4) = xyLine(1);
            dat(k,5) = xyLine(2);
        end
    end
    datN = length(dat);
    dat = int32(dat);
    dispInROIcells('Green','L',datN)
    saveData('Green','L',dat);
    distOfGreen_InLeft = dat;
    %waitbar(0.6, hB, 'Compute Map (approx 5min) ...');  
    
    %% Select in_R with Red Tracer
    xTemp = xBig(in_R);
    yTemp = yBig(in_R);
    n1 = length(xTemp);
    strInROI = get(hObjInROI,'String');   
    strInROI = ['R' num2str(n1) '/' strInROI];
    set(hObjInROI,'String', strInROI);   
    
    k = 0; dat = [];   
    for i = 1:n1
        [i_2] = getInd(xTemp(i), yTemp(i));
        if cBig(i_2,1) %red
            k = k + 1;
            dat(k,1) = xTemp(i);
            dat(k,2) = yTemp(i);
            if strcmp(dataCompute,'ROI'), continue; end;            
            [xyLine,dist,t_a] = distance2curve(refLine_R,[xTemp(i) yTemp(i)],'linear');
            %[xy,distance,t_a] = distance2curve(curvexy,mapxy,'linear');
            [xyLine1,dist1,t_a1] = distance2curve(xyLine,refPoint_R,'linear');
            [xyLine2,dist2,t_a2] = distance2curve(refPoint_R,[xTemp(i) yTemp(i)],'linear');
            %disp(['dist1 ' num2str(dist1) '; dist2 ' num2str(dist2)]);
            if dist1 >= dist2
                     dat(k,3) = (-1)*dist;
                     line([xTemp(i), xyLine(1)],[yTemp(i), xyLine(2)],'LineWidth',1,'Color','r');
            else
                     dat(k,3) = dist;
                     line([xTemp(i), xyLine(1)],[yTemp(i), xyLine(2)],'LineWidth',1,'Color','m');
            end
            dat(k,4) = xyLine(1);
            dat(k,5) = xyLine(2);
        end
    end
    datN = length(dat);
    dat = int32(dat);
    dispInROIcells('Red','R',datN)
    saveData('Red','R',dat);
    distOfRed_InRight = dat;
    %waitbar(0.8, hB, 'Compute Map (approx 5min) ...');   
    
    %% Select in_R with Green Tracer
    k = 0; dat = [];   
    for i = 1:n1
        [i_2] = getInd(xTemp(i), yTemp(i));
        if cBig(i_2,2) %green
            k = k + 1;
            dat(k,1) = xTemp(i);
            dat(k,2) = yTemp(i);
            if strcmp(dataCompute,'ROI'), continue; end;
            [xyLine,dist,t_a] = distance2curve(refLine_R,[xTemp(i) yTemp(i)],'linear');
            %[xy,distance,t_a] = distance2curve(curvexy,mapxy,'linear');
            [xyLine1,dist1,t_a1] = distance2curve(xyLine,refPoint_R,'linear');
            [xyLine2,dist2,t_a2] = distance2curve(refPoint_R,[xTemp(i) yTemp(i)],'linear');
            %disp(['dist1 ' num2str(dist1) '; dist2 ' num2str(dist2)]);
            if dist1 >= dist2
                     dat(k,3) = (-1)*dist;
                     line([xTemp(i), xyLine(1)],[yTemp(i), xyLine(2)],'LineWidth',1,'Color','c');
            else
                     dat(k,3) = dist;
                     line([xTemp(i), xyLine(1)],[yTemp(i), xyLine(2)],'LineWidth',1,'Color','g');
            end
            dat(k,4) = xyLine(1);
            dat(k,5) = xyLine(2);
        end
    end
    datN = length(dat);
    dat = int32(dat);
    dispInROIcells('Green','R',datN)
    saveData('Green','R',dat);
    distOfGreen_InRight = dat;
    if strcmp(dataCompute,'ROI'), return; end;
        
    %% Get distance figure; only flatMaps are flipped from now on
    distOfRed_InLeftDeep  = []; distOfRed_InLeftSup   = [];
    distOfRed_InRightDeep = []; distOfRed_InRightSup  = [];
    distOfGreen_InLeftDeep  = []; distOfGreen_InLeftSup   = [];
    distOfGreen_InRightDeep = []; distOfGreen_InRightSup  = [];
    
    if ~isempty(distOfRed_InLeft)
        idx = (distOfRed_InLeft(:,3)<=0); distOfRed_InLeftDeep = distOfRed_InLeft(idx,:);
        idx = (distOfRed_InLeft(:,3)>0);  distOfRed_InLeftSup  = distOfRed_InLeft(idx,:);
    end
    
    if ~isempty(distOfRed_InRight)
        idx = (distOfRed_InRight(:,3)<=0); distOfRed_InRightDeep = distOfRed_InRight(idx,:);
        idx = (distOfRed_InRight(:,3)>0);  distOfRed_InRightSup  = distOfRed_InRight(idx,:);
    end
    
    if ~isempty(distOfGreen_InLeft)
        idx = (distOfGreen_InLeft(:,3)<=0); distOfGreen_InLeftDeep = distOfGreen_InLeft(idx,:);
        idx = (distOfGreen_InLeft(:,3)>0);  distOfGreen_InLeftSup  = distOfGreen_InLeft(idx,:);
    end
    
    if ~isempty(distOfGreen_InRight)
        idx = (distOfGreen_InRight(:,3)<=0); distOfGreen_InRightDeep = distOfGreen_InRight(idx,:);
        idx = (distOfGreen_InRight(:,3)>0);  distOfGreen_InRightSup  = distOfGreen_InRight(idx,:);
    end
    
    %% Get flatMap deep
    hD = figure('Tag', 'tracerPlot', 'Name', ['Tracer Plot ' batchRoot]);
    subplot(2,2,1);
    title('Subplot 1: distOfRed inLeft');
        if flipS
            fnD = [batchRoot 'analysis2\flatDist_red_in_RightHDeep.mat'];
            fnS = [batchRoot 'analysis2\flatDist_red_in_RightHSup.mat'];
            subplot(2,2,2);
            [projDistD] = computeDistance(distOfRed_InLeftDeep,refLine_L, refPoints_L);
            [projDistS] = computeDistance(distOfRed_InLeftSup,refLine_L, refPoints_L);
            str1 = ['flatDistance saved for redR.'];
            str2 = 'Subplot 2: distOfRed inRight';
        else
            fnD = [batchRoot 'analysis2\flatDist_red_in_LeftHDeep.mat'];
            fnS = [batchRoot 'analysis2\flatDist_red_in_LeftHSup.mat'];
            subplot(2,2,1);
            [projDistD] = computeDistance(distOfRed_InLeftDeep,refLine_L, refPoints_L);
            [projDistS] = computeDistance(distOfRed_InLeftSup,refLine_L, refPoints_L);
            str1 = ['flatDistance saved for redL.'];
            str2 = 'Subplot 1: distOfRed inLeft';
        end            
        flatDistD = int32(projDistD);
        plot(projDistD,1,'r.');
        save(fnD, 'flatDistD');
        distNd = length(projDistD);
        flatDistS = int32(projDistS);
        plot(projDistS,1.5,'r.');
        save(fnS, 'flatDistS');
        distNs = length(projDistS);
        disp(['D' num2str(distNd) 'S' num2str(distNs) ' ' str1]);
        title(str2);
    if isempty(distOfRed_InLeft)
        disp('No tracer positive cell found for redL.');
    end        
    axis([-40000, 60000, 0, 2]);
    hold on       

    subplot(2,2,2);
    title('Subplot 2: distOfRed inRight');
        if flipS
            fnD = [batchRoot 'analysis2\flatDist_red_in_LeftHDeep.mat'];
            fnS = [batchRoot 'analysis2\flatDist_red_in_LeftHSup.mat'];
            subplot(2,2,1);
            [projDistD] = computeDistance(distOfRed_InRightDeep,refLine_R, refPoints_R);
            [projDistS] = computeDistance(distOfRed_InRightSup,refLine_R, refPoints_R);
            str1 = 'flatDistance saved for redL.';
            str2 = 'Subplot 1: distOfRed inLeft';
        else
            fnD = [batchRoot 'analysis2\flatDist_red_in_RightHDeep.mat'];
            fnS = [batchRoot 'analysis2\flatDist_red_in_RightHSup.mat'];
            subplot(2,2,2);
            [projDistD] = computeDistance(distOfRed_InRightDeep,refLine_R, refPoints_R);
            [projDistS] = computeDistance(distOfRed_InRightSup,refLine_R, refPoints_R);
            str1 = 'flatDistance saved for redR.';
            str2 = 'Subplot 2: distOfRed inRight';
        end            
        flatDistD = int32(projDistD);
        plot(projDistD,1,'r.');
        save(fnD, 'flatDistD');
        distNd = length(projDistD);
        flatDistS = int32(projDistS);
        plot(projDistS,1.5,'r.');
        save(fnS, 'flatDistS');
        distNs = length(projDistS);
        disp(['D' num2str(distNd) 'S' num2str(distNs) ' ' str1]);
        title(str2);
    if isempty(distOfRed_InRight)
        disp('No tracer positive cell found for redR.');
    end
    axis([-40000, 60000, 0, 2]);
    hold on
    
    subplot(2,2,3);
    title('Subplot 3: distOfGreen inLeft');
        if flipS
            fnD = [batchRoot 'analysis2\flatDist_green_in_RightHDeep.mat'];
            fnS = [batchRoot 'analysis2\flatDist_green_in_RightHSup.mat'];
            subplot(2,2,4);
            [projDistD] = computeDistance(distOfGreen_InLeftDeep,refLine_L, refPoints_L);
            [projDistS] = computeDistance(distOfGreen_InLeftSup,refLine_L, refPoints_L);
            str1 = 'flatDistance saved for greenR.';
            str2 = 'Subplot 4: distOfGreen inRight';
        else
            fnD = [batchRoot 'analysis2\flatDist_green_in_LeftHDeep.mat'];
            fnS = [batchRoot 'analysis2\flatDist_green_in_LeftHSup.mat'];
            subplot(2,2,3);
            [projDistD] = computeDistance(distOfGreen_InLeftDeep,refLine_L, refPoints_L);
            [projDistS] = computeDistance(distOfGreen_InLeftSup,refLine_L, refPoints_L);
            str1 = 'flatDistance saved for greenL.';
            str2 = 'Subplot 3: distOfGreen inLeft';
        end            
        flatDistD = int32(projDistD);
        plot(projDistD,1,'r.')
        save(fnD, 'flatDistD');
        distNd = length(projDistD);
        flatDistS = int32(projDistS);
        plot(projDistS,1.5,'r.')
        save(fnS, 'flatDistS');
        distNs = length(projDistS);
        disp(['D' num2str(distNd) 'S' num2str(distNs) ' ' str1]);
        title(str2);
    if isempty(distOfGreen_InLeft)
        disp('No tracer positive cell found for greenL.');
    end        
    axis([-40000, 60000, 0, 2]);
    hold on
 
    subplot(2,2,4);
    title('Subplot 4: distOfGreen inRight');
        if flipS
            fnD = [batchRoot 'analysis2\flatDist_green_in_LeftHDeep.mat'];
            fnS = [batchRoot 'analysis2\flatDist_green_in_LeftHSup.mat'];
            subplot(2,2,3);
            [projDistD] = computeDistance(distOfGreen_InRightDeep,refLine_R, refPoints_R);
            [projDistS] = computeDistance(distOfGreen_InRightSup,refLine_R, refPoints_R);
            str1 = ['flatDistance saved for greenL.'];
            str2 = 'Subplot 3: distOfGreen inLeft';
        else
            fnD = [batchRoot 'analysis2\flatDist_green_in_RightHDeep.mat'];
            fnS = [batchRoot 'analysis2\flatDist_green_in_RightHSup.mat'];
            subplot(2,2,4);
            [projDistD] = computeDistance(distOfGreen_InRightDeep,refLine_R, refPoints_R);
            [projDistS] = computeDistance(distOfGreen_InRightSup,refLine_R, refPoints_R);
            str1 = ['flatDistance saved for greenR.'];
            str2 = 'Subplot 4: distOfGreen inRight';
        end            
        flatDistD = int32(projDistD);
        plot(projDistD,1,'r.')
        save(fnD, 'flatDistD');
        distNd = length(projDistD);
        flatDistS = int32(projDistS);
        plot(projDistS,1.5,'r.')
        save(fnS, 'flatDistS');
        distNs = length(projDistS);
        disp(['D' num2str(distNd) 'S' num2str(distNs) ' ' str1]);
        title(str2);
    if isempty(distOfGreen_InRight)
        disp('No tracer positive cell found for greenR.');
    end
    axis([-40000, 60000, 0, 2]);
    set(gcf, 'InvertHardCopy', 'off');
    print(hD, '-dpng', '-r600', [batchRoot 'analysis2\flatMapFigure.png']);   
    %saveas(hD,[batchRoot 'analysis2\flatMapFigure.png']);
    set(hObject,'Value',1);
    %waitbar(1, hB, 'Compute Map (approx 5min) ...');  
    %close(hB);
    disp('Step8 Done.');
end


function ind = getInd(xTemp, yTemp)
global xBig yBig

ind = NaN;
i1 = find(xBig == xTemp);
i2 = find(yBig == yTemp);
i3 = [i1; i2];
i3 = i3';
a = unique(i3);
b = histc(i3,a);
c = a(b>1);
%c = find(i3==a(b>1));
if length(c) ~= 1
    errordlg('getInd in Step8 is NaN. Test');
    return
end
ind = c(1);


function minVal = getMin(C)
B = nonzeros(C);
minVal = min(B);


% --- Executes during object creation, after setting all properties.
function nTiles_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function nCells_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Set Menu Bar
function set_menu(fig_id,eventdata,handles)
set(fig_id, 'MenuBar', 'none', 'Units', 'Normalized');
%set(fig_id, 'Position', [0 0 1 1], 'DefaultUicontrolUnits', 'Normalized');

menu_file = uimenu(fig_id, 'Label', 'File');
menu_file_open = uimenu(menu_file, 'Label', 'Open stack...',...
    'Callback','import_data_Callback()'); %hObject, eventdata, handles)');
menu_file_save = uimenu(menu_file, 'Label', 'Save results...',...
    'Callback','save_data()');
menu_file_exit = uimenu(menu_file, 'Label', 'Exit', ...
    'Callback', 'delete(fig_id); close all; clear;');

menu_tools = uimenu(fig_id, 'Label', 'Tools');
menu_tools_plot = uimenu(menu_tools, 'Label', 'Copy All 2.5xb images',...
    'Callback', 'copy_all_b()');
menu_tools_plot2 = uimenu(menu_tools, 'Label', 'Copy All Big Plot figures',...
    'Callback', 'copy_all_bigPlot()');
menu_tools_setDir = uimenu(menu_tools, 'Label', 'Update Tile Input_Image.xml Files',...
    'Callback', 'updateInputImageXMLFilesTile()');
menu_tools_graphType = uimenu(menu_tools, 'Label', 'Get Tracer Flat Maps',...
    'Callback', 'getFlatMaps()');
    %test BrainSegmenterGUI('last_frame_Callback',hObject,eventData,guidata(hObject))
menu_tools_graphType2 = uimenu(menu_tools, 'Label', 'Run Step on All Sections',...
    'Callback', 'BrainSegmenterGUI(''runStepOnAllSections'',fig_id,eventdata'')');
    %'Callback', 'runStepOnAllSections()');
menu_help = uimenu(fig_id, 'Label', 'Help');


function pushbutton10_Callback(hObject, eventdata, handles)


function save_Callback(hObject, eventdata, handles)
global batchRoot batchName

% if  isempty(batchRoot)
%     set(hObject,'Value',0);
%     errordlg('No Image Analysis Project opened.');
%     return
% end
%Exiting, do you want to save changes
% need to decide what to save
h = msgbox('No data to save. Save Done.');
pause(1);
close(h);


function scaleLines_Callback(hObject, eventdata, handles)
global batchRoot bigWidth bigHeight

[status] = scaleAllLines();

if status
    h = msgbox('Scale All lines done.');
    pause(2);
    close(h);
else
    h = msgbox('Error while scale line.');
end


function greenTracer_Callback(hObject, eventdata, handles)
global xBig yBig cBig

hFig = findobj('Tag', 'bigPlot');
%axes(handles.axes1);
    if isempty(hFig)
          errordlg('Big Plot figure not found');
          return
    end
figure(hFig); hold on
sel = get(hObject,'Value');
if sel
    xG = xBig(cBig(:,2)>0);
    if isempty(xG) 
        msgbox('No tracer info available, might need to run Step4-5.');
        set(hObject,'Value', 0);
        return
    end
    yG = yBig(cBig(:,2)>0);
    plot(xG,yG,'g.','MarkerSize', 4);
else
    plot(xBig,yBig,'b.','MarkerSize', 1);     
end


function redTracer_Callback(hObject, eventdata, handles)
global xBig yBig cBig

hFig = findobj('Tag', 'bigPlot');
%axes(handles.axes1);
    if isempty(hFig)
          errordlg('Big Plot figure not found');
          return
    end
    figure(hFig); 
hold on
sel = get(hObject,'Value');
if sel
    xR = xBig(cBig(:,1)>0);
    if isempty(xR) 
        msgbox('No tracer info available, might need to run Step4-5.');
        set(hObject,'Value', 0);        
        return
    end
    yR = yBig(cBig(:,1)>0);
    plot(xR,yR,'r.','MarkerSize', 4);    
else
    plot(xBig,yBig,'b.','MarkerSize', 1); 
end


function tilesGrid_Callback(hObject, eventdata, handles)
global tileWidth tileHeight
global iTiles jTiles

sel = get(hObject,'Value');
hFig = findobj('Tag', 'bigPlot');
if isempty(hFig)
      errordlg('Big Plot figure not found');
      if sel
            set(hObject,'Value',0);
      else
            set(hObject,'Value',1);
      end
      return
end
if sel
    if ~tileWidth, updatePara; end;
    figure(hFig);  hold on
    
    %{
    %test
    %h = axis;  gca;
    axis on; h = gca;
    set(h,'GridLineStyle','-');
    set(h,'LineWidth',2);
    set(h,'XTickMode','manual');
    x1 = 0; x2 = tileWidth; x3 = tileWidth*2; x4 = tileWidth*3;
    set(h,'XTick',[x1:x2:x3:x4]);
    set(h,'XGrid','on')
    set(h,'YTickMode','manual');
    y1 = 0; y2 = tileHeight; y3 = tileHeight*2; y4 = tileHeight*3;
    set(h,'YTick',[y1:y2:y3:y4]);
    set(h,'YGrid','on')
    axis on
    %axis off       
    %}
    tileX = [0 tileWidth*jTiles]; 
    for k = 1:iTiles-1
        tileY = [tileHeight*k tileHeight*k]; 
        plot(tileX, tileY, 'g-');
        hold on
    end
    tileY = [0 tileHeight*iTiles]; 
    for k = 1:jTiles-1
        tileX = [tileWidth*k tileWidth*k];
        plot(tileX, tileY, 'g-');
        hold on
    end    
else
    %close fig and redraw it again
    hLines = findall(hFig,'type', 'line', 'color', 'g');
    delete(hLines);   
end


function redTreshold_Callback(hObject, eventdata, handles)
global redTresh
% hObject    handle to redTreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of redTreshold as text
%        str2double(get(hObject,'String')) returns contents of redTreshold as a double
val = get(handles.redTreshold,'string');
disp(['redTresh ' val]);
redTresh = str2double(val); 
saveProgressToXML({{'Section' 'redTresh' val}});


% --- Executes during object creation, after setting all properties.
function redTreshold_CreateFcn(hObject, eventdata, handles)
global redTresh
% hObject    handle to redTreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function greenTreshold_Callback(hObject, eventdata, handles)
global greenTresh
% hObject    handle to greenTreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of greenTreshold as text
%        str2double(get(hObject,'String')) returns contents of greenTreshold as a double
val = get(handles.greenTreshold,'string');
disp(['greenTresh ' val]);
greenTresh = str2double(val); 
saveProgressToXML({{'Section' 'greenTresh' val}});


% --- Executes during object creation, after setting all properties.
function greenTreshold_CreateFcn(hObject, eventdata, handles)
global greenTresh
% hObject    handle to greenTreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
strVal = num2str(greenTresh);
set(hObject,'String', strVal);


function niTiles_Callback(hObject, eventdata, handles)
% hObject    handle to niTiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of niTiles as text
%        str2double(get(hObject,'String')) returns contents of niTiles as a double


% --- Executes during object creation, after setting all properties.
function niTiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to niTiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function njTiles_Callback(hObject, eventdata, handles)
% hObject    handle to njTiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of njTiles as text
%        str2double(get(hObject,'String')) returns contents of njTiles as a double


% --- Executes during object creation, after setting all properties.
function njTiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to njTiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% choice = questdlg(['Exiting. Save Analysis Results ?'],'Save Analysis',...
%     'Yes','No','No');
% if strcmp(choice,'Yes')
%      BrainSegmenterGUI('save_Callback',hObject,eventdata,guidata(hObject));
% end
clear all;
clc;
close all;
h = msgbox('Close Analysis Done.');
pause(1);
close(h);
run BrainSegmenterGUI;


function maxRedTresh_Callback(hObject, eventdata, handles)
global maxRedTresh
% hObject    handle to maxRedTresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxRedTresh as text
%        str2double(get(hObject,'String')) returns contents of maxRedTresh as a double
val = get(handles.maxRedTresh,'string');
disp(['maxRedTresh ' val]);
maxRedTresh = str2double(val); 
saveProgressToXML({{'Section' 'maxRedTresh' val}});
%#


% --- Executes during object creation, after setting all properties.
function maxRedTresh_CreateFcn(hObject, eventdata, handles)
global maxRedTresh
% hObject    handle to maxRedTresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxGreenTresh_Callback(hObject, eventdata, handles)
global maxGreenTresh
% hObject    handle to maxGreenTresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxGreenTresh as text
%        str2double(get(hObject,'String')) returns contents of maxGreenTresh as a double
val = get(handles.maxGreenTresh,'string');
disp(['maxGreenTresh ' val]);
maxGreenTresh = str2double(val); 
saveProgressToXML({{'Section' 'maxGreenTresh' val}});


% --- Executes during object creation, after setting all properties.
function maxGreenTresh_CreateFcn(hObject, eventdata, handles)
global maxGreenTresh
% hObject    handle to maxGreenTresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in flipS.
function flipS_Callback(hObject, eventdata, handles)
global flipS
% hObject    handle to flipS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipS
val = get(hObject,'Value');
val = num2str(val);
disp(['flipS ' val]);
flipS = str2double(val); 
saveProgressToXML({{'Section' 'flipS' val}});


% --- Executes on button press in runAllDataAnalysis.
function runAllDataAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to runAllDataAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global batchRoot

xmlFile = [batchRoot 'ImageAnalysisProgress.xml'];    
loadProgressFromXML(xmlFile);
if  isempty(batchRoot)
    set(hObject,'Value',0);
    errordlg('No Image Analysis Project opened.');
    return
end

BrainSegmenterGUI('step6_Callback',hObject,eventdata,guidata(hObject));
BrainSegmenterGUI('step7_Callback',hObject,eventdata,guidata(hObject));
BrainSegmenterGUI('step8_Callback',hObject,eventdata,guidata(hObject));
disp('runAllDataAnalysis Done.');


function allRedV_Callback(hObject, eventdata, handles)
% hObject    handle to allRedV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of allRedV as text
%        str2double(get(hObject,'String')) returns contents of allRedV as a double


% --- Executes during object creation, after setting all properties.
function allRedV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allRedV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function allGreenV_Callback(hObject, eventdata, handles)
% hObject    handle to allGreenV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of allGreenV as text
%        str2double(get(hObject,'String')) returns contents of allGreenV as a double


% --- Executes during object creation, after setting all properties.
function allGreenV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allGreenV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function redInROI_Callback(hObject, eventdata, handles)
% hObject    handle to redInROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of redInROI as text
%        str2double(get(hObject,'String')) returns contents of redInROI as a double


% --- Executes during object creation, after setting all properties.
function redInROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to redInROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function greenInROI_Callback(hObject, eventdata, handles)
% hObject    handle to greenInROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of greenInROI as text
%        str2double(get(hObject,'String')) returns contents of greenInROI as a double


% --- Executes during object creation, after setting all properties.
function greenInROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to greenInROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nCells_Callback(hObject, eventdata, handles)
% hObject    handle to nCells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nCells as text
%        str2double(get(hObject,'String')) returns contents of nCells as a double


% --- Executes on button press in useROI.
function runAllSect_Test_Callback(hObject, eventdata, handles)
% hObject    handle to useROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useROI
global batchRoot

%% LM, Mar2014
sel = get(hObject,'Value');
if sel
%% select Processed Sections
dn = uigetdir('',...
    'Select Processed directory to open');
if isequal(dn,0)
   disp('User selected Cancel');
   return
else
   disp(['User selected ', dn])
end

%% get sectList
% 4test   dn = 'V:\analysisAll'; [dn fn ext] = fileparts(dn); sectList = [10; 25; 79; 109; 115; 187; 193; 199; 211; 217]; %importdata([dn '\' fn]);
sectList0 = dir(dn);
sectList = []; %{}; j = 0;
for i = 1:length(sectList0)
    dnVar0 = str2num(sectList0(i).name);
    dnVar  = dnVar0; %dnVar0(1);
    if ~isempty(dnVar) && isa(dnVar,'numeric')
        sectList = [sectList, dnVar0];
    end
end
%sectList = sectList';
sectList = sort(sectList);

%% Run Step
dn = [dn '\'];
%run BrainSegmenterGUI;
nS = length(sectList);
nS2 = nS;

for k = 1:nS
    sect = sectList(k);
    dnVar = num2str(sect);
    dName  = [dn dnVar '\analysis'];
    dName2 = [dn dnVar '\analysis2'];
    if ~exist(dName,'dir') && ~exist(dName2,'dir')
        nS2 = nS2 - 1;
        continue
    end
    
    if sect == 21 || sect == 27
        batchRoot = [dn num2str(sect) '\'];
        %delete([batchRoot,'*.xml']);
        BrainSegmenterGUI('openAnalysis_Callback',hObject,eventdata,guidata(hObject),sect);
        BrainSegmenterGUI('runAllDataAnalysis_Callback',hObject,eventdata,guidata(hObject));
        %BrainSegmenterGUI('close_Callback',hObject,eventdata,guidata(hObject));
        hFig = findobj('Tag', 'bigPlot');
        if ~isempty(hFig)
             close(hFig);
        end
        hFig = findobj('Tag', 'tracerPlot');
        if ~isempty(hFig)
             close(hFig);
        end
        disp(['== S' num2str(sect) ' runAllDataAnalysis Done. Folder ' batchRoot]);
    end
end
disp(['=== Run Step On All Sections: Done. Total sections: ' num2str(nS2) ' from ' num2str(nS)]);
end


% --- Executes on selection change in listbox6.
function listbox6_Callback(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox6


% --- Executes during object creation, after setting all properties.
function listbox6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox7.
function listbox7_Callback(hObject, eventdata, handles)
% hObject    handle to listbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox7


% --- Executes during object creation, after setting all properties.
function listbox7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in rotateMenu.
function rotateMenu_Callback(hObject, eventdata, handles)
% hObject    handle to rotateMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rotateMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rotateMenu
%global MClust_Marks
var1 = get(hObject,'Value');
switch var1
    case 2
        rotateVar = 'Right'
    case 3
        rotateVar = 'Left'
    otherwise 
        rotateVar = 'None'
end;
saveProgressToXML({{'Section' 'rotate' rotateVar}});


% --- Executes during object creation, after setting all properties.
function rotateMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotateMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dataComputeMenu.
function dataComputeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to dataComputeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dataComputeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dataComputeMenu
var1 = get(hObject,'Value');
switch var1
    case 2
        dataComputeVar = 'ROI'
    otherwise 
        dataComputeVar = 'Distance'
end;
saveProgressToXML({{'Section' 'dataCompute' dataComputeVar}});


% --- Executes during object creation, after setting all properties.
function dataComputeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataComputeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nTiles_Callback(hObject, eventdata, handles)
% hObject    handle to nTiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nTiles as text
%        str2double(get(hObject,'String')) returns contents of nTiles as a double


function cellsInROI_Callback(hObject, eventdata, handles)
% hObject    handle to cellsInROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellsInROI as text
%        str2double(get(hObject,'String')) returns contents of cellsInROI as a double


% --- Executes during object creation, after setting all properties.
function cellsInROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellsInROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in flipMenu.
function flipMenu_Callback(hObject, eventdata, handles)
% hObject    handle to flipMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns flipMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from flipMenu
var1 = get(hObject,'Value');
switch var1
    case 2
        flipVar = 'flipX'
    case 3
        flipVar = 'flipY'
    otherwise 
        flipVar = 'None'
end;
saveProgressToXML({{'Section' 'flipImage' flipVar}});


% --- Executes during object creation, after setting all properties.
function flipMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flipMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function allCellsV_Callback(hObject, eventdata, handles)
% hObject    handle to allCellsV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of allCellsV as text
%        str2double(get(hObject,'String')) returns contents of allCellsV as a double


% --- Executes during object creation, after setting all properties.
function allCellsV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allCellsV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to allGreenV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of allGreenV as text
%        str2double(get(hObject,'String')) returns contents of allGreenV as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allGreenV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to allRedV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of allRedV as text
%        str2double(get(hObject,'String')) returns contents of allRedV as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allRedV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function x2p5int2 = applyOffset(x2p5int)
global batchRoot regisRoot 
global flipS sectName

x2p5int2 = x2p5int;
% [dn fn ext] = fileparts(batchRoot);
% [dn fn ext] = fileparts(dn);
% sectName = fn;
 sect = str2num(sectName);
% dn = [dn '/ndpi4regis/'];
% regisRoot = dn;
if isempty(x2p5int2) % no tracer points
    return
end
dn = regisRoot;
list  = dir([dn '*offsets.csv']);
if ~isempty(list) %offset file exists
    fn = [dn list(1).name];
    offSets = []; 
    offSets = csvread(fn);
    i = find(offSets(:,1)==sect);
    if ~isempty(i) %section offset found
        xo = offSets(i,2);
        yo = offSets(i,3);
        disp(['Offset to apply: (' num2str(xo) ',' num2str(yo) ')']);
        x2p5int2(:,1) = x2p5int2(:,1)+xo;
        x2p5int2(:,2) = x2p5int2(:,2)+yo;
    end
end
if flipS
    disp('Flip section data.');
    x = inputdlg('Enter uncut section width in pixels:',...
             'Section Width', [1 50]);
   w = str2num(x{:}); 
   x2p5int2(:,1) = w - x2p5int2(:,1);
end


% --- Executes on button press in viewMetadata.
function viewMetadata_Callback(hObject, eventdata, handles)
% hObject    handle to viewMetadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[fn, dn, ext] = uigetfile({'*.xml';'*.*'},'Select the ODML Metadata file');

fullFN = fullfile(dn, fn);
if isequal(fn,0)
    disp('User selected Cancel');
    return
else
    disp(['User selected: ' fullFN]);
end

web(fullFN)

% [fn3 dn3 ex3] = fileparts(fn);
% projectID = dn3;
% hFig2 = findobj('Name','allSectionsView');
% update Experiment name


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in runOnAllSections.
function runOnAllSections_Callback(hObject, eventdata, handles)
% hObject    handle to runOnAllSections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns runOnAllSections contents as cell array
%        contents{get(hObject,'Value')} returns selected item from runOnAllSections
global brainRoot

var1 = get(hObject,'Value');

choice = questdlg('Confirm to run step on all sectons: ','All Sections',...
                  'Yes','No','No');
if strcmp(choice,'No'), return; end

switch var1
    case 2
        disp('Step0');
        BrainSegmenterGUI('step0_Callback',hObject,eventdata,guidata(hObject));
    case 3
        disp('Step1');
        BrainSegmenterGUI('step1_Callback',hObject,eventdata,guidata(hObject));
    case 4
        disp('Step2');
        BrainSegmenterGUI('step2_Callback',hObject,eventdata,guidata(hObject));
    case 5
        disp('Step3');
        BrainSegmenterGUI('step3_Callback',hObject,eventdata,guidata(hObject));
    case 6
        disp('Step4');
        BrainSegmenterGUI('step4_Callback',hObject,eventdata,guidata(hObject));
    case 7
        disp('Step5');        
        BrainSegmenterGUI('step5_Callback',hObject,eventdata,guidata(hObject));
    case 8
        getNdpi4Regis();
    case 9
        splitChannelsBatchMode();
    case 10
        getGUIcounts();
    otherwise 
        %rotateVar = 'None'
end;
%saveProgressToXML({{'Section' 'flipImage' rotateVar}});


% --- Executes during object creation, after setting all properties.
function runOnAllSections_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runOnAllSections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useROI.
function useROI_Callback(hObject, eventdata, handles)
% hObject    handle to useROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useROI
global batchRoot sectName

hFig = findobj('Tag', 'bigPlot');
if isempty(hFig)
      errordlg('Big Plot figure not found.');
      return
end
figure(hFig);
h = imfreehand;
%position = wait(h); 
pos = getPosition(h);
choice = questdlg('Save ROI? ','ROI',...
                  'Yes','No','No');
if strcmp(choice,'Yes')
    csvFN = [batchRoot sectName '_40xROI.txt'];
    if exist(csvFN,'file')
        delete(csvFN);
    end
    csvwrite(csvFN,pos);
end


% --- Executes on button press in viewAllSections.
function viewAllSections_Callback(hObject, eventdata, handles)
% hObject    handle to viewAllSections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global batchRoot sectName 
global brainID brainRoot allSinfo

%% check if brain ID already selected
if isempty(brainID)
    if isempty(batchRoot)
        %select brain root folder
        brainRoot = uigetdir('','Brain Root Directory')
    else
        [dn fn ext] = fileparts(batchRoot);
        [dn fn ext] = fileparts(dn);
        [dn fn ext] = fileparts(dn);
        brainRoot = dn;
    end

    %set brainID
    [dn fn ext] = fileparts(brainRoot);
    brainID = fn;
    hObj = findobj('Tag', 'tabBrain');
    set(hObj, 'Title', ['Brain: ' brainID]);
end
getAllSinfo;
allSectionsView;
% xmlFile = [batchRoot 'ImageAnalysisProgress.xml'];
% if exist(xmlFile, 'file')
%     hM = msgbox('Progress XML file exists. Loading analysis...');
%     updateControls(xmlFile);
% else
% end
