function saveProgressToXML(para)
% para - a cell array of name/attr/value elements to save, 
%        if attr is empty, it's the name value 
% para = {{'Tiles' 'iTiles' '2'};...
%         {'Tiles' 'jTiles' '2'};...
%         {'step0' 'Status' 'Done'};...
%         {'imgName' '' 'ndpiFileName'};...
%         {'batchRoot' '' batchRoot}};

%% Last Modified by Lilia Mesina, CCBN, Dec2013

global batchRoot

fn = [batchRoot '\ImageAnalysisProgress.xml'];
if ~exist(fn,'file')
    errordlg('Can''t open file ImageAnalysisProgress.xml.');
   return
end

xDoc = xmlread(fn);
%theStruct = parseXML(fn);
n = length(para);
for i=1:n
     %read new para/value
     itemI = para{i};
     if isempty(itemI), continue; end
     %disp(itemI);
     thisList = xDoc.getElementsByTagName(itemI(1));
     if ~thisList.getLength()
         msgbox(['XML element ' itemI(1) ' not found. Continue.']);
         continue
     end
     thisElement = thisList.item(0);
     if strcmp(itemI(2),'')
         thisElement.getFirstChild.setNodeValue(itemI(3));
     else
         thisElement.setAttribute(itemI(2),itemI(3));
     end
end
xmlwrite(fn,xDoc);
updateControls(fn);
disp('Progress saved to XML file.');
