clc;
clear all;
close all;

tilts = 0:1:2;

for j = 1:length(tilts)
    
    fprintf('-------------------------------\n')
    fprintf('Running tilt = %d ...\n',tilts(j))
    power_map_and_path_tilt(tilts(j));
    fprintf('Finished tilt = %d\n',tilts(j))
    fprintf('-------------------------------\n')
    
end