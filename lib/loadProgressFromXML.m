function loadProgressFromXML(fn)
%% Last Modified by  LM, Dec2013

global imgName batchRoot batchName 
global iTiles jTiles nTiles
global redTresh greenTresh 
global maxGreenTresh maxRedTresh flipS
global bigWidth bigHeight nCells
global tileWidth tileHeight
global imageAnalysisStatus rotate dataCompute
global step0 step1 step2 step3 step4 step5

%{
%test
%to avoid error "Reference to a cleared variable"

imgName = ''; batchRoot = ''; batchName = ''; 
iTiles = 0; jTiles = 0; nTiles = 0; redTresh = 0; greenTresh = 0; 
maxGreenTresh = 0; maxRedTresh = 0; bigWidth = 0; bigHeight = 0; nCells = 0;
tileWidth = 0; tileHeight = 0;
imageAnalysisStatus = ''; step0 = ''; step1 = ''; step2 = ''; 
step3 = ''; step4 = ''; step5 = '';
%}

%% init
xDoc = xmlread(fn);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('bigWidth'));
bigWidth = str2num(val);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('bigHeight'));
bigHeight = str2num(val);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('nCells'));
nCells = str2num(val);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('redTresh'));
redTresh = str2num(val);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('greenTresh'));
greenTresh = str2num(val);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('maxRedTresh'));
maxRedTresh = str2num(val);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('flipS'));
flipS = str2num(val);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('maxGreenTresh'));
maxGreenTresh = str2num(val);

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('rotate'));
rotate = val;

thisList = xDoc.getElementsByTagName('Section');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('dataCompute'));
dataCompute = val;

thisList = xDoc.getElementsByTagName('imgName');
thisElement = thisList.item(0);
imgName = char(thisElement.getFirstChild.getData);

thisList = xDoc.getElementsByTagName('batchRoot');
thisElement = thisList.item(0);
batchRoot = char(thisElement.getFirstChild.getData);

thisList = xDoc.getElementsByTagName('batchName');
thisElement = thisList.item(0);
batchName = char(thisElement.getFirstChild.getData);

thisList = xDoc.getElementsByTagName('Tiles');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('iTiles'));
iTiles = str2num(val);

thisList = xDoc.getElementsByTagName('Tiles');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('jTiles'));
jTiles = str2num(val);

thisList = xDoc.getElementsByTagName('Tiles');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('nTiles'));
nTiles = str2num(val); %or = iTiles * jTiles

thisList = xDoc.getElementsByTagName('Tile');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('tileWidth'));
tileWidth = str2num(val);

thisList = xDoc.getElementsByTagName('Tile');
thisElement = thisList.item(0);
val = char(thisElement.getAttribute('tileHeight'));
tileHeight = str2num(val);

thisList = xDoc.getElementsByTagName('ImageAnalysis');
thisElement = thisList.item(0);
imageAnalysisStatus = char(thisElement.getAttribute('Status'));
		
thisList = xDoc.getElementsByTagName('step0');
thisElement = thisList.item(0);
step0 = char(thisElement.getAttribute('Status'));

thisList = xDoc.getElementsByTagName('step1');
thisElement = thisList.item(0);
step1 = char(thisElement.getAttribute('Status'));

thisList = xDoc.getElementsByTagName('step2');
thisElement = thisList.item(0);
step2 = char(thisElement.getAttribute('Status'));

thisList = xDoc.getElementsByTagName('step3');
thisElement = thisList.item(0);
step3 = char(thisElement.getAttribute('Status'));

thisList = xDoc.getElementsByTagName('step4');
thisElement = thisList.item(0);
step4 = char(thisElement.getAttribute('Status'));

thisList = xDoc.getElementsByTagName('step5');
thisElement = thisList.item(0);
step5 = char(thisElement.getAttribute('Status'));
