function startup()
%% matlab search path
homeGUI = which('BrainSegmenterGUI');
addpath(genpath(homeGUI)); %(genpath(pwd));
h = msgbox('BrainSegmenterGUI Path Loaded!');
pause(1);
close(h);
run BrainSegmenterGUI;
