function loadRefs(name,ab,lr)
%% Last Modified by LM, 20Apr2015

global allRefs batchRoot
global refLine_L refLine_R
    str1 = [batchRoot 'line\'];
    str2 = ['*' name '_' ab '_' lr '_new.txt'];
    %fList = dir([str1 '*V1_a_*_new.txt']); 
    fList = dir([str1 str2]); 
    nFiles = length(fList);
    if ~nFiles
       msgH = msgbox(['For ' str2 ' no files found.']);
       pause(1);
       close(msgH);
       return
%     elseif nFiles > 2 
%        errordlg(['For ' str2 'more than 2 files found (left/right only).']);
%        return
    end
    n = length(allRefs);
    n = n + 1;
    allRefs{n} = [];
    allRefs{n}.name = [name '_' lr];
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
        text(refLine(1,1),refLine(1,2),['\color{white}' name ab]);
        hold on
        if strcmp(lr,'L')
            x2 = refLine_L(:,1)';  
            y2 = refLine_L(:,2)';
        else
            x2 = refLine_R(:,1)';  
            y2 = refLine_R(:,2)';
        end
        if ~isempty(strfind(fullFN,['a_' lr '_new']))
            x1 = refLine(:,1)';
            y1 = refLine(:,2)';
            P = InterX([x1;y1],[x2;y2]);
            %refPoints_L = [refPoints_L; P(1) P(2)];
            plot(P(1),P(2),'gX');
            allRefs{n}.ax = x1;
            allRefs{n}.ay = y1;
            allRefs{n}.aOnLine = P;
        elseif ~isempty(strfind(fullFN,['b_' lr '_new']))
            x1 = refLine(:,1)';
            y1 = refLine(:,2)';
            P = InterX([x1;y1],[x2;y2]);
            %refPoints_R = [refPoints_R; P(1) P(2)];
            plot(P(1),P(2),'gX');
            allRefs{n}.bx = x1;
            allRefs{n}.by = y1;
            allRefs{n}.bOnLine= P;
        else
            errordlg('Test. Can''t decide on L/R.');
            return
        end
        allRefs{n}.aDist = 0;
        allRefs{n}.bDist = 0;
    end