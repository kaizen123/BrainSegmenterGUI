function copy_all_bigPlot()
%% Last Modified by LM, Apr2014

global batchRoot 

%% copy bigPlotFigure to 'ndpi_all_b' folder

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
    str1 = [dn '\' dName '\analysis\bigPlotFigure.png'];
    dList2 = dir(str1);
    str12 = [dn '\' dName '\analysis2\bigPlotFigure.png'];
    dList22 = dir(str12);
    if length(dList2)==1
        str2 = [dn '\' dName '\analysis\' dList2(1).name];
        str3 = [to_dn dName '_bigPlot.jpg'];
        copyfile(str2, str3);
        disp(['Copy ' str2]);
        disp([' to  ' str3]);
        nn = nn + 1;
    else
       if length(dList22)==1
            str2 = [dn '\' dName '\analysis2\' dList22(1).name];
            str3 = [to_dn dName '_2bigPlot.jpg'];
            copyfile(str2, str3);
            disp(['Copy ' str2]);
            disp([' to  ' str3]);
            nn = nn + 1;
       end
    end
end
disp(['Copy All Big Plot Figure Done. Total files: ' num2str(nn)]);
