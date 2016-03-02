function updateInputImageXMLFiles()
%% LM, Jan2014

global batchRoot 

%copy *b.tif to 'ndpi_all_b'
[dn] = uigetdir(batchRoot, 'Select Directory with all Sections');

dList1 = ddir(dnn);
nFiles = length(dList1);
nn = 0;

for i = 1:nFiles
    dName1 = dList1(i).name;
    str2 = [dn '\' dName1 '\batch_*'];
    dList2 = dir(str2);
    if length(dList2)==1
        dName2 = dList2(1).name;
        str3 = [dn '\' dName1 '\' dName2 '\*_processed'];
        dList3 = dir(str3);
        nD = length(dList3);
        for k = 1:nD
            dName3 = [dn '\' dName1 '\' dName2 '\' dList3(k).name];
            createInputImageXML(dName3);
            disp(['Recreated file Input_Image.xml in folder: ' dName3]);
            nn = nn + 1;
            return
        end
    end
end
disp(['Update All Input_Image.xml files: Done. Total files: ' num2str(nn)]);
