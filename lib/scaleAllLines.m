function [status new_fn] = scaleAllLines
%LM, Dec2013
global batchRoot imgName bigWidth bigHeight

%loadProgressFromXML(xmlFile);
imgList = dir([batchRoot '\' imgName '_x2*b.tif']);
if length(imgList) == 1
    imgFN = [batchRoot imgList(1).name];
    imgInfo = imfinfo(imgFN);
    imgInfo = imgInfo(1);
    x2_5x = imgInfo.Width;
    y2_5x = imgInfo.Height;
else
    errordlg('Can''t open 2.5x tif image.');
    status = 0;
    new_fn = [];
    return
end

if ~bigWidth || ~bigHeight
    errordlg('Can''t find bigWidth|bigHeight.');
    status = 0;
    new_fn = [];
    return
end
x40x = bigWidth;
y40x = bigHeight;

str1 = [batchRoot '\line\']; 
if ~exist(str1,'dir')
    errordlg('Can''t open 2.5x tif image.');
    status = 0;
    new_fn = [];
    return
end
hB = waitbar(0, 'Scale lines in progress  ...');   
tList = dir([str1 '*.txt']); 
nFiles = length(tList);
waitbar(0.05, hB, 'Scale lines in progress  ...');   
for i=1:nFiles
    fn = tList(i).name;
    if strfind(fn,'_new'), continue; end
    fullFN = [str1 fn];
    %copyfile(str2, [dn 'ProjectDef_seg.xml']);
    xy1 = importdata(fullFN);
    n = length(xy1);
    xy2 = zeros(n,2);

    x2Ratio = x40x / x2_5x;
    y2Ratio = y40x / y2_5x;

    xy2(:,1) = xy1(:,1) * x2Ratio;
    xy2(:,2) = xy1(:,2) * x2Ratio;
    
    [d f e] = fileparts(fullFN);
    new_fn = [d '\' f '_new' e];
    xy2n = xy2;
    
    if strcmp(f(end),'S') %smooth only layer reference lines
        para1 = 8
        para2 = 1
        disp(['Smooth ' fullFN]);    
        xy2n(:,1) = runline(xy2(:,1),para1,para2); %smooth 5,1, from Chronux web
        xy2n(:,2) = runline(xy2(:,2),para1,para2); %smooth 5,1, from Chronux web
    end
    

    fid = fopen(new_fn, 'w');
    refLineNew = round(xy2n);
    fprintf(fid,'%3d %3d\r\n',refLineNew'); %,round(xy2n(:,2)));
    %save(new_fn, 'xy2n', '-ASCII', '-tabs');
    fclose(fid);
    waitbar(i/nFiles, hB, 'Scale lines in progress  ...');   
end
waitbar(1, hB, 'Scale lines in progress  ...');   
close(hB);
status = 1;