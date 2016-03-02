function copy_all_b()
%% LM, Jan2014

global batchRoot 

% copy *b.tif to 'ndpi_all_b'

[dn] = uigetdir(batchRoot, 'Select Directory with all Sections');

if ~dn
    msgbox('User selected Cancel.');
    return
end

to_dn = [dn '\ndpi_all_b\'];

dList = dir(dn);
nFiles = length(dList);
nn = 0;

for i = 1:nFiles
    dName = dList(i).name;
    str1 = [dn '\' dName '\*b.tif'];
    dList2 = dir(str1);
    if length(dList2)==1
        str2 = [dn '\' dName '\' dList2(1).name];
        str3 = [to_dn '\' dName '.tif'];
        copyfile(str2, str3);
        disp(['Copy ' str2]);
        disp([' to  ' str3]);
        nn = nn + 1;
    end
end
disp(['Copy All 2.5x images: Done. Total images: ' num2str(nn)]);
