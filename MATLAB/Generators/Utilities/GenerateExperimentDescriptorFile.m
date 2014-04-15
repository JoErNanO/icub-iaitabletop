function [ res ] = GenerateExperimentDescriptorFile(fileName, data, expType)
%GENERATEEXPERIMENTDESCRIPTORFILE Generate the experiment descriptor file
%(.ini).
%   Detailed explanation goes here


%% Check experiment type
if strcmp(expType, 'recfield')
    header = [ '# This is the Receptive Field Exploration experiment. \n', ...
        '# The probe starts at the given position and moves along a linear trajectory along the y axis in steps of 0.1mm. \n', ...
        '# At each horizontal step, the probe depth is incremented and decremented in the same number of steps of ', num2str((data(3, 3) - data(2, 3)) / 1000), 'mm. \n'];
elseif strcmp(expType, 'progdepth')
    header = [ '# This is the Progressive Depth experiment. \n', ...
        '# The probes starts centered on the given taxel and moves along the z axis following a return trajectory of ', int2str(size(data, 1) - 2), ' steps. \n', ...
        '# At each depth variation the probe position is altered in steps of ', num2str((data(3, 3) - data(2, 3)) / 1000), 'mm. \n'];
else
    error('GenerateExperimentDescriptorFile:UnknownExperimentType', ['Cannot generate the experiment descriptor file for the given experiment type: ', expType]);
end


%% Store data in file
fid = fopen(fileName, 'w+');

% Header
fprintf(fid, '# ########################################################################### \n');
fprintf(fid, '# Experiment descriptor file \n');
fprintf(fid, '# ########################################################################### \n');
fprintf(fid, '# \n');
fprintf(fid, header);       % Add customised header per experiment
fprintf(fid, ['# Each depth position is maintained for ', int2str(data(2, end)), ' seconds.  \n']);
fprintf(fid, '\n');

% Experiment param block
fprintf(fid, '[experiment]\n');
fprintf(fid, '# Number of columns in the posVelAccDecTime array below: \n');
fprintf(fid, ['#   (X Y Z velX velY velZ accX accY accZ decX decY decZ t) = ', int2str(size(data, 2)), ' \n']);
fprintf(fid, ['nCols ', int2str(size(data, 2)), '\n']);
fprintf(fid, '\n');

% posVelAccDecTime array block
fprintf(fid, ['# Position values are in um (10^-3)mm \n']);
fprintf(fid, ['# Velocities are in mm/s \n']);
fprintf(fid, ['# Accelerations/Decelerations are in 10^-2G \n']);
fprintf(fid, ['#   (X Y Z velX velY velZ accX accY accZ decX decY decZ t) = ', int2str(size(data, 2)), ' \n']);
fprintf(fid, 'posVelAccDecTime (\n');

for i = 1:size(data, 1)
    fprintf(fid, '\t');
    for j = 1:size(data, 2)
        fprintf(fid, '%i', data(i, j));
        fprintf(fid, ' ');
    end
    fprintf(fid, '\\\n');
end
fprintf(fid, ')');
fclose(fid);


end

