function sList = getProcessedSectionList(dn)
%% LM, feb2015

% loop through the dn folder and select sections where exist file ImageAnalysisProgress.xml
sList = [];
files = dir(dn);
filenames = {files.name};
subdirs = filenames([files.isdir]);
for s = 1:length(subdirs)
  subdir = subdirs{s};
  [sn, status] = str2num(subdir);
  if status
%       fnXML = [dn subdir '\ImageAnalysisProgress.xml'];
%       if exist(fnXML, 'file'), sList = [sList sn]; end
      sList = [sList sn];
  end
end
sList = sort(sList);
