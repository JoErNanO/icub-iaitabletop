function [res] = LoadTableTopData(trial, varargin)
%LOADTABLETOPFATA Loads the data from the tabletop dump and
%preprocesses it. The dump contains raw fingertip skin values and nano17 ft
%sensor values.
%
%
% Input:
%
%       trial - trial number
%
%       varargin - list of tuples (parameter, value).
%           Valid parameters are:
%               Filter ('on', 'off') - Filter the data to remove spikes
%
%
% Output:
%       
%       res - result data structure with the following fields:
%               robot - string identifying the robot name
%               trial - trial number
%               date - the trial date
%               ftipRaw - data from the raw fingertip skin sensor
%               nano - data from the external Nano17 Force/Torque sensor
%               pos - data from the position of the TableTop robot
%               exp - experiment status data (n_step, t_start, t_end) for
%                  each step
%               activeTaxels - the taxels activated during the trial
%               baselines - the sensor baselines computed by averaging
%                   values over 15 seconds without load
%


%% Build path from input parameters
trial = sprintf('%05d', trial);
trialpath = strcat('/dump_', trial);

nanopath = which(['tabletop/data/nano17', trialpath, '/data.log']);
skinpathRaw = which(['tabletop/data/fingertip', trialpath, '/data.log']);
pospath = which(['tabletop/data/iaittpos', trialpath, '/data.log']);
exppath = which(['tabletop/data/iaittexp', trialpath, '/data.log']);

%% Check for the existence of the data
if ~exist(nanopath, 'file')
    error('LoadFingertipsData:FileNotFound', ['Could not find the Nano17 sensor data for trial number ', trial, '.', ...
        '\n', 'Path requested was: ', nanopath]);
elseif ~exist(skinpathRaw, 'file')
    error('LoadFingertipsData:FileNotFound', ['Could not find the Skin sensor Raw data for trial number ', trial, '.', ...
        '\n', 'Path requested was: ', skinpathRaw]);
elseif ~exist(pospath, 'file')
    error('LoadFingertipsData:FileNotFound', ['Could not find the IAI TT position data for trial number ', trial, '.', ...
        '\n', 'Path requested was: ', pospath]);
elseif ~exist(exppath, 'file')
    error('LoadFingertipsData:FileNotFound', ['Could not find the IAI TT experiment data for trial number ', trial, '.', ...
        '\n', 'Path requested was: ', exppath]);
end


%% Extract variable input args
% Build parser
p = inputParser;
% Filter spikes
defaultFilt = 'off';
validFilt = {'on', 'off'};
checkFilt = @(x) any(validatestring(x, validFilt));
addOptional(p, 'Filter', defaultFilt, checkFilt);
% Parse
parse(p, varargin{:});


%% Load the data
% Nano17 data
load(nanopath);
tmpNano = data;
clear data;
% Skin data
load(skinpathRaw);
tmpSkinRaw = data;
clear data;
% Position data
load(pospath);
tmpPos = data;
clear data;
% Experiment data
load(exppath);
tmpExp = data;
clear data;


%% Postprocess the data
% Nano17 - eliminate useless pck id column
if (~isempty(tmpNano))
    nano = tmpNano(:, 2:end);
end
clear tmpNano;
% Skin
% Eliminate useless pck id column
if (~isempty(tmpSkinRaw))
    ftipRaw = tmpSkinRaw(:, 2:end);
end
clear tmpSkinRaw;
% Reverse data (0-255)
% ftipRaw(:, 3:end) = 255 - ftipRaw(:, 3:end);
% Position - eliminate useless pck id column
if (~isempty(tmpPos))
    pos = tmpPos(:, 2:end);
end
clear tmpPos;
% Experiment - eliminate useless pck id column
if (~isempty(tmpExp))
    exp = tmpExp(:, 2:end);
end
clear tmpExp;


%% Filter out spikes
if strcmpi(p.Results.Filter, 'on')
    fprintf('Filtering out spikes from data. \n');
    nano = FilterOutSpikes(nano, exp, 3);
    ftipRaw = FilterOutSpikes(ftipRaw, exp, 3);
    pos = FilterOutSpikes(pos, exp, 3);
    fprintf('Done. \n');
end


%% Compute baselines
% Mean of first step -> (t_0 >= t_start_1) & (t <= t_end_1)
baselines = cell(3, 1);
% Skin
indexes = (ftipRaw(:, 1) >= exp(1, 3)) & (ftipRaw(:, 1) <= exp(1, 4));
baselines{1} = mean(ftipRaw(indexes, 2:end));
% Nano17
indexes = (nano(:, 1) >= exp(1, 3)) & (nano(:, 1) <= exp(1, 4));
baselines{2} = mean(nano(indexes, 2:end));
% Pos
indexes = (pos(:, 1) >= exp(2, 3)) & (pos(:, 1) <= exp(2, 4));
baselines{3} = mean(pos(indexes, 2:end));


%% Find active taxels
taxels = 2:13;
standdev = std(ftipRaw(:, taxels));
activeTaxels = taxels(standdev >= mean(standdev) + std(standdev))


%% Build result structure
% Data
res.robot = 'TableTop';
res.trial = trial;
% res.date = datestr(TimeUnix2Matlab(ftipRaw(1, 1) * 1000), 'yyyymmdd-HH:MM:SS');
res.date = datestr(TimeUnix2Matlab(ftipRaw(1, 1)), 'yyyymmdd-HH:MM:SS');
res.nano = nano;
res.ftipRaw = ftipRaw;
res.pos = pos;
res.exp = exp;
res.activeTaxels = activeTaxels;
res.baselines = baselines;
% Other paramters
res.fzIndex = 4;
res.posYIndex = 3;

end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter out the spikes from the data
function [res] = FilterOutSpikes(data, expvals, Z)
%FILTEROUTSPIKES Filter out the spikes from the time series.
% Spikes are often found in data points which correspond to robot movements
% and that are therefore not counted as being "experiment steps".
% Moreover this function also filters out data points which are beyond Z
% standard deviations away from the mean.


%% Filter out spikes using Z standard deviation rule
tmpRes = zeros(size(data));
indexes = false(size(data(:, 1), 1), 1);
% Loop experiment steps
for i = 1:size(expvals, 1)
   % Find data values for current experiment step
   idx = (data(:, 1) >= expvals(i, 3)) & (data(:, 1) <= expvals(i, 4));
   % Get data subset
   datasub = data(idx, :);
   % Find local mean and std
   mu = mean(datasub);
   sd = std(datasub);
   
   % Find outliers using Z stand dev rule
   %    abs(X - mu) > (Z * sd)
   outl = bsxfun(@gt, abs(bsxfun(@minus, datasub, mu)), Z*sd);
   % Filter out outliers
   for j = 1:size(datasub, 2)
       datasub(outl(:, j), j) = mu(j) .* sign(datasub(outl(:, j)));
   end
%    datasub(outl) = bsxfun(@times, Z*sd, sign(datasub(outl)));
   
   % Store filtered data
   tmpRes(idx, :) = datasub;
   
   indexes = indexes | idx;
end


%% Filter out data points which do not belong to any experiment step
tmpRes(~indexes, :) = [];


%% Build result
res = tmpRes;

end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
