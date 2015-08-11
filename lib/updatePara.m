function updatePara
%% Last Modified by Lilia Mesina, 20Jun2014

global imgName batchRoot batchName
global iTiles jTiles nTiles
global tileWidth tileHeight 
global bigWidth bigHeight rotate


fileFN = [batchRoot batchName '\i1j1\i1j1.tif'];
if exist(fileFN, 'file')
    imgInfo = imfinfo(fileFN);
    imgInfo = imgInfo(1);
    tileWidth = imgInfo.Width;
    tileHeight = imgInfo.Height;
else
    errordlg('Can''t open i1j1 tif image to get tile dimensions.');
    status = 0;
    new_fn = [];
    return
end

bigWidth = tileWidth*jTiles; %61080; %## get image info just before saving i1j1.tif
bigHeight = tileHeight*iTiles; %39888;
nTiles = iTiles*jTiles;
para = {{'step1' 'Status' 'Done'};...
        {'Tiles' 'iTiles' num2str(iTiles)};...
        {'Tiles' 'jTiles' num2str(jTiles)};...
        {'Tiles' 'nTiles' num2str(nTiles)};...
        {'Tile'  'tileWidth' num2str(tileWidth)};...
        {'Tile'  'tileHeight' num2str(tileHeight)};...
        {'Section'  'bigWidth' num2str(bigWidth)};...
        {'Section'  'bigHeight' num2str(bigHeight)}};
saveProgressToXML(para);
