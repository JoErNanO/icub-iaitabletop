function [ res ] = GenerateExperimentParamsProgressiveDepth(taxel, varargin)
%GENERATEEXPERIMENTPARAMSPROGRESSIVEDEPTH Generate the parameters for the
%progressive depth experiment and stores them in an experiment descriptor
%file (.ini).
%
%
% INPUT:
%       taxel - string representing the taxel on which to press. Can be 
%           either 'L' or 'R'
%
%
% OUTPUT:
%       res - m-by-n array of experiment parameters where m is the number
%           of steps and n is the number of parameters for each step
%


%% Extract variable input args
% Build parser
p = inputParser;
% Probe width
defProbe = '2';
validProbe = {'2', '4', '5', '6'};
checkIncrement = @(x) any(validatestring(x, validProbe));
addOptional(p, 'Probe', defProbe, checkIncrement);
% Depth step size
defIncrement = '0.1';
validIncrement = {'0.1', '0.05', '0.025', '0.005', '0.001'};
checkIncrement = @(x) any(validatestring(x, validIncrement));
addOptional(p, 'DIncr', defIncrement, checkIncrement);
% Max depth
defMaxDepth = '0.4';
validMaxDepth = {'0.05', '0.1', '0.15', '0.2', '0.25', '0.3', '0.35', '0.4'};
checkMaxDepth = @(x) any(validatestring(x, validMaxDepth));
addOptional(p, 'DMax', defMaxDepth, checkMaxDepth);
% Parse
parse(p, varargin{:});


%% Experiment parameters
% First noload position - used to compute the baseline
tBase = 60;
% Position time
tStep = 60;
% Last noload position - used to compute the hystheresis time constant
tLast = tStep^2 / 6;        % Small for small depths
% tLast = t^2;                % Large for large depths
% Velocity
vel.x = 20;
vel.y = 20;
vel.z = 20;
% Acceleration
acc.x = 1;
acc.y = 1;
acc.z = 1;
% Deceleration
dec.x = 1;
dec.y = 1;
dec.z = 1;


%% Get taxel and set starting coordinates
start.x = 20224;
if (strcmpi(taxel, 'l'))
    start.y = 76024;
    start.z = FindStartingDepth(str2double(p.Results.Probe), 1);
elseif (strcmpi(taxel, 'r'))
    start.y = 71536;
    start.z = FindStartingDepth(str2double(p.Results.Probe), 2);
else
    error('GenerateProgressiveDepthExperimentParams:UnknownTaxelType', ['Cannot generate the progressive depth experiment parameters for the given taxel: ', taxel, '.']);
end
   

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate depth coordinates
% Depth parameters
maxDepth = str2double(p.Results.DMax) * 1000;
depth.increment = str2double(p.Results.DIncr) * 1000;
depth.steps = maxDepth / depth.increment;
depth.start = start.z;

% Depth profile
depthProfile = GenerateProgressiveDepth(depth.start, depth.steps, depth.increment);
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%% Initialise result structure
res = zeros(size(depthProfile, 1) + 2, 13);
% Add no load step to compute baseline
res(1, :) = [start.x, start.y, start.z - 8000, vel.x, vel.y, vel.z, acc.x, acc.y, acc.z, dec.x, dec.y, dec.z, tBase];
res(2:end, 1) = start.x;
res(2:end, 2) = start.y;
res(2:end-1, 3) = depthProfile;
res(2:end-1, 4:end) = repmat([vel.x, vel.y, vel.z, acc.x, acc.y, acc.z, dec.x, dec.y, dec.z, tStep], size(depthProfile, 1), 1);
% Add final no load step to compute long t_k for baseline return
res(end, :) = [start.x, start.y, start.z - 8000, vel.x, vel.y, vel.z, acc.x, acc.y, acc.z, dec.x, dec.y, dec.z, tLast];


%% Store data in file
GenerateExperimentDescriptorFile(['confIAITableTopExperiment-ProgressiveDepth-Taxel', upper(taxel), '-Probe', p.Results.Probe, 'mm.ini'], res, 'progdepth');


end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res] = FindStartingDepth(probe, taxel)
%FindStartingDepth Finds the experiment starting depth depending on the
%probe width

%% Set lookup table
depths = zeros(6, 2);
% Starting depths
%                 L      R
depths(1, :) = [88560, 88760];      % 1mm
depths(2, :) = [88560, 88760];      % 2mm
depths(3, :) = [88560, 88760];      % 3mm
depths(4, :) = [88560, 88760];      % 4mm
depths(5, :) = [88250, 88700];      % 5mm
depths(6, :) = [88100, 88300];      % 6mm


%% Find depth
res = depths(probe, taxel);

end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%