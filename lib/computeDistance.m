function [distance] = computeDistance(distB,refLine,refPs)
%% Last Modified by LM, Dec2013

%% Part1 - unroll refLine
%if refPs(1) is close to refLine(end) => need to flipup(refLine)
d1 = pdist([refPs(1,:);refLine(1,:)], 'euclidean');
d2 = pdist([refPs(1,:);refLine(end,:)], 'euclidean');
if d1 > d2
    refLine = flipud(refLine);
end
A = refLine; %line points
%for test
%B = double(distB(:,4:5)); %points of projections on the line
%B = double(B);
%--figure; plot(A(:,1),A(:,2),'ro',B(:,1),B(:,2),'bx');

%% insert refPoints(1) in refLine
%[xyLine,dist,t_a] = distance2curve(refLine_R,[refP(1,1) refP(1,2)],'linear');
nL = length(A);
%find i1, where A(i1) is the closiest point to refP1
tempM = pdist([refPs(1,:);A], 'euclidean');
tempM = tempM(1,1:nL);
min1 = min(tempM);
i1 = find(tempM == min1);
i1 = i1(1);
%find i2, where A(i2) is the second closiest point to refP1
tempM2 = tempM;
tempM(tempM <=min1) = NaN;
min2 = min(tempM);
i2 = find(tempM == min2);
i2 = i2(1);
iMin = min([i1 i2]);
%insert refP1 in A
indRefP1 = iMin+1;
A = [A(1:iMin,:); refPs(1,:); A(iMin+1:nL,:)];
%% #==
nL = length(A);
%find i1, where A(i1) is the closiest point to refP2
tempM = pdist([refPs(2,:);A], 'euclidean');
tempM = tempM(1,1:nL);
min1 = min(tempM);
i1 = find(tempM == min1);
i1 = i1(1);
%find i2, where A(i2) is the second closiest point to refP1
tempM2 = tempM;
tempM(tempM <=min1) = NaN;
min2 = min(tempM);
i2 = find(tempM == min2);
i2 = i2(1);
iMin = min([i1 i2]);
%insert refP2 in A
indRefP2 = iMin+1;
A = [A(1:iMin,:); refPs(2,:); A(iMin+1:nL,:)];
%refLine = A;

%% unroll A (refLineAll)
%get x+
nLine = length(A);
lineDist = zeros(nLine,1);
%nLinePlus = length(A(indRefP1:nLine,1));
for i = indRefP1+1:nLine
    lineDist(i) = lineDist(i-1) + pdist([A(i-1,:); A(i,:)], 'euclidean'); 
end
%get x-
for i = indRefP1-1:-1:1
    lineDist(i) = lineDist(i+1) - pdist([A(i+1,:); A(i,:)], 'euclidean'); 
end

xPlot = lineDist;
%4test
%--figure; yPlot = ones(length(xPlot));hold on
%--plot(xPlot,yPlot,'b.'); hold on 
plot(xPlot(indRefP1),1,'b*',xPlot(indRefP2),1,'gx','MarkerSize',10,'LineWidth',4);
plot(xPlot(indRefP1),1.5,'b*',xPlot(indRefP2),1.5,'gx','MarkerSize',10,'LineWidth',4);
hold on

var0 = lineDist(indRefP1)+lineDist(indRefP2); %test
if var0 ~= lineDist(indRefP2)
    errordlg('RefPoints not properly set in computeDistance(). Test');
    return
end

%% Part2: for each projection point find 2 closiest points on the line
projDist = [];
if ~isempty(distB)
    B = double(distB(:,4:5)); %points of projections on the line
    nProj = size(B);
    nProj = nProj(1);
    for i = 1:nProj
        tempM = pdist([B(i,:);A], 'euclidean');
        tempM = tempM(1,1:nLine);
        %find i1, where A(i1) is  the closiest point to Bi
        min1 = min(tempM); %has to be unique, unless A1B = BA2, in the midle 
        i1 = find(tempM == min1);
        %if length(i1) > 1, error('Min1 isn''t unique!'); end
        i1 = i1(1);
        if min1 == 0 
            projDist(i) = lineDist(i1); 
            continue; 
        end
        %distA1 = lineDist(i1(1));

        %find i2, where A(i2) is the second closiest point to Bi
        tempM2 = tempM;
        tempM(tempM <=min1) = NaN;
        min2 = min(tempM);
        i2 = find(tempM == min2);
        %if length(i2) > 1, error('Min2 isn''t unique!'); end
        i2 = i2(1);
        if min2 == 0 
            projDist(i) = lineDist(i2); 
            continue; 
        end
        %distA2 = lineDist(i2(1));

        %get distnce of Bi
        iMin = min([i1 i2]);
        if iMin >= indRefP1
            projDist(i) = lineDist(iMin) + tempM2(iMin);
        else
            projDist(i) = lineDist(iMin) - tempM2(iMin);
        end
    end
end

%% Part3: clean points after indRefP2
var1 = lineDist(indRefP2);
distance = projDist; %(projDist <= var1);
distance = [distance, xPlot(indRefP2)];

