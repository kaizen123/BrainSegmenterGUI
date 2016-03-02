function createInputImageXMLfile(dn)
%LM, 18Apr2013

cd(dn);
fileList = dir('*RAW.tif');
if length(fileList)~= 3
    disp(['Error: Input image file missing/tooMany in folder ' dn]);
    return
end

docNode = com.mathworks.xml.XMLUtils.createDocument('Image');
docRootNode = docNode.getDocumentElement;
for i1 = 1:length(fileList) 
    fileName = fileList(i1);  
    if strfind(fileName.name, 'blue')
        thisElement = docNode.createElement('file'); 
        thisElement.setAttribute('chname','Dapi');
        thisElement.setAttribute('r','0');
        thisElement.setAttribute('g','0');
        thisElement.setAttribute('b','255');
        thisElement.appendChild(docNode.createTextNode([dn '\' fileName.name]));
        docRootNode.appendChild(thisElement);
    end
    if strfind(fileName.name, 'green')
        thisElement = docNode.createElement('file'); 
        thisElement.setAttribute('chname','Homer');
        thisElement.setAttribute('r','0');
        thisElement.setAttribute('g','255');
        thisElement.setAttribute('b','0');
        thisElement.appendChild(docNode.createTextNode([dn '\' fileName.name]));
        docRootNode.appendChild(thisElement);
    end
    if strfind(fileName.name, 'red')
        thisElement = docNode.createElement('file'); 
        thisElement.setAttribute('chname','Arc');
        thisElement.setAttribute('r','255');
        thisElement.setAttribute('g','0');
        thisElement.setAttribute('b','0');
        thisElement.appendChild(docNode.createTextNode([dn '\' fileName.name]));
        docRootNode.appendChild(thisElement);
    end
end
xmlFileName = [dn '\Input_image.xml'];
disp(['Create XML file ' xmlFileName])
xmlwrite(xmlFileName,docNode);