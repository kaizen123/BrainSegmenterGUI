function plotGreyAxes()
%LM, 10Aug2014

%figure(hFig);
hold on; grid off

xtick = get(gca,'XTick'); 
ytick = get(gca,'YTick'); 
ylim = get(gca,'Ylim');
xlim = get(gca,'Xlim');

Y = repmat(ytick,2,1);
X = repmat(xlim',1,size(ytick,2));

plot(X,Y,'Color',[0.8 0.8 0.8])
