function getAllSinfo
global allSinfo brainRoot
global step0 step1 step2 step3 step4 step5

%% get all sections info from the xml files
% allSinfo.cnames = {'s1', 's2'}
% allSinfo.data = {true, true, false}
dn = [brainRoot '\processed'];
sList = getProcessedSectionList(dn);
allSinfo.cnames = strread(num2str(sList),'%s');
%num2cell{sList};
n = length(sList);
d = false(7,n);
for i = 1:n
    fnXML = [dn '\' num2str(sList(i)) '\ImageAnalysisProgress.xml'];
    if exist(fnXML, 'file')
        loadProgressFromXML(fnXML);
        tmpD = [0; strcmp(step0,'Done'); strcmp(step1,'Done'); ...
            strcmp(step2,'Done');strcmp(step3,'Done'); ...
            strcmp(step4,'Done');strcmp(step5,'Done')];
        d(:,i) = logical(tmpD); 
    else
        d(:,i) = [false; false; false; false; false; false; false];         
    end

end
allSinfo.data = d;
