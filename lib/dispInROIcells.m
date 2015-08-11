function dispInROIcells(channel, side, in)
% Lilia Mesina, Polaris/CCBN, November2013
% ==
% Last Modified by LM, 2Jun2014

global in_L in_R

%s = [channel side];
switch channel
        case 'Red'
            hObj = findobj('Tag','redInROI');
        case 'Green'
            hObj = findobj('Tag','greenInROI');
        otherwise
            errordlg('Can''t decide on Left/Right ROI in func dispInROICells.');
end
val = in; %length(in);   
strVal = [side num2str(val)];
strVal0 = get(hObj,'String');   
if strVal0, strVal = [strVal '/' strVal0]; end
set(hObj,'String', strVal);             
disp([channel ' in ' side ' ROI: ' strVal]);
