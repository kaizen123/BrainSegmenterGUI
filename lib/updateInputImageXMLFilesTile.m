function updateInputImageXMLFilesTile()
%% LM, Jan2014

global batchRoot 

[dn] = uigetdir(batchRoot, 'Select batch directory');

str3 = [dn  '\*_processed'];
dList3 = dir(str3);
nD = length(dList3);
for k = 1:nD
    dName3 = [dn '\' dList3(k).name];
    createInputImageXML(dName3);
    %disp(['Recreated file Input_Image.xml in folder: ' dName3]);
end
disp(['=== Update All Input_Image.xml files: Done. Total files: ' num2str(nD)]);
