function startup()
%% matlab search path
pathFiji = ''; %'C:\Users\user\Desktop\Fiji.app' %set this up before you start, so Miji will work
addpath(genpath(pathFiji));

homeGUI = which('BrainSegmenterGUI');
addpath(genpath(homeGUI)); %(genpath(pwd));
h = msgbox('BrainSegmenterGUI Path Loaded!');
pause(1);
close(h);
run BrainSegmenterGUI;
