function loadRefs(name,ab,lr)
global allRefs batchRoot
global refLine_L refLine_R
    str1 = [batchRoot 'line\'];
    str2 = ['*' name '_' ab '_' lr '_new.txt'];
%    fList = dir([str1 '*V1_a_*_new.txt']); 
    fList = dir([str1 str2]); 
    nFiles = length(fList);
    if ~nFiles
       errordlg(['For ' str2 ' no files found.']);
       return
%     elseif nFiles > 2 
%        errordlg(['For ' str2 'more than 2 files found (left/right only).']);
%        return
    end
    n = length(allRefs);
    n = n + 1;
    allRefs(n) = [];
    allRefs(n).name = [name '_' lr];
    for i = 1:nFiles
        fullFN = [str1 fList(i).name];
        disp(fullFN);
        [refLine] = importdata(fullFN);
        hFig = findobj('Tag', 'bigPlot');
        if isempty(hFig)
              errordlg('Big Plot figure not found');
              return
        end   
        figure(hFig); 
        hold on
        plot(refLine(:,1),refLine(:,2),'r-');
        hold on
        if ~isempty(strfind(fullFN,['a_' lr '_new']))
            x1 = refLine(:,1)';
            y1 = refLine(:,2)';
            x2 = refLine_L(:,1)';  
            y2 = refLine_L(:,2)';
            P = InterX([x1;y1],[x2;y2]);
            %refPoints_L = [refPoints_L; P(1) P(2)];
            plot(P(1),P(2),'gX');
            allRefs(1).ax = x1;
            allRefs(1).ay = y1;
            allRefs(1).aOnLine = P;
        elseif ~isempty(strfind(fullFN,['b_' lr '_new']))
            x1 = refLine(:,1)';
            y1 = refLine(:,2)';
            x2 = refLine_R(:,1)';
            y2 = refLine_R(:,2)';
            P = InterX([x1;y1],[x2;y2]);
            refPoints_R = [refPoints_R; P(1) P(2)];
            plot(P(1),P(2),'gX');
            allRefs(1).bx = x1;
            allRefs(1).by = y1;
            allRefs(1).bOnLine= P;
        else
            errordlg('Test. Can''t decide on L/R.');
            return
        end
        allRefs(1).aDist = 0;
        allRefs(1).bDist = 0;
    end