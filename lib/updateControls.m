function updateControls(xmlFile)
% Lilia Mesina, Polaris/CCBN, May2014
% ==
% Last Modified by LM, 29May2014

global iTiles jTiles nTiles nCells
global rotate dataCompute
global step0 step1 step2 step3 step4 step5

loadProgressFromXML(xmlFile);   
if isempty(rotate), rotate = 'None'; end
switch rotate
    case 'Right'
        rotateVal = 2;
    case 'Left'
        rotateVal = 3;
    case 'Flip'
        rotateVal = 4;
    otherwise
        rotateVal = 1;
end

if isempty(dataCompute), dataCompute = 'Distance'; end
switch dataCompute
    case 'ROI'
        dataComputeVal = 2;
    otherwise
        dataComputeVal = 1;
end

hObj = findobj('Tag','niTiles');
strVal = num2str(iTiles);
set(hObj,'String', strVal);
hObj = findobj('Tag','njTiles');
strVal = num2str(jTiles);
set(hObj,'String', strVal);
hObj = findobj('Tag','nTiles');
strVal = num2str(nTiles);
set(hObj,'String', strVal);
hObj = findobj('Tag','nCells');
strVal = num2str(nCells);
set(hObj,'String', strVal);
hObj = findobj('Tag','rotateMenu');
set(hObj,'String', 'None|Right|Left|Flip', 'Value', rotateVal);
hObj = findobj('Tag','dataComputeMenu');
set(hObj,'String', 'Distance|ROI', 'Value', dataComputeVal);
val = strcmp(step0,'Done');
hObj = findobj('Tag', 'step0');
set(hObj,'Value', val);
val = strcmp(step1,'Done');
hObj = findobj('Tag', 'step1');
set(hObj,'Value', val);
val = strcmp(step2,'Done');
hObj = findobj('Tag', 'step2');
set(hObj,'Value', val);
val = strcmp(step3,'Done');
hObj = findobj('Tag', 'step3');
set(hObj,'Value', val);
val = strcmp(step4,'Done');
hObj = findobj('Tag', 'step4');
set(hObj,'Value', val);
val = strcmp(step5,'Done');
hObj = findobj('Tag', 'step5');
set(hObj,'Value', val);    
