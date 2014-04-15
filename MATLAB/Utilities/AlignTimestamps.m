function [ res ] = AlignTimestamps(data)
%ALIGNTIMESTAMPS Align the timestamps of the data time series using a
%commont starting point.
%  
%
% Input:
%
%       data - data structure with the following fields:
%               robot - string identifying the robot name
%               trial - trial number
%               date - the trial date
%               ftipRaw - data from the raw fingertip skin sensor
%               nano - data from the external Nano17 Force/Torque sensor
%               pos - data from the position of the TableTop robot
%               exp - experiment status data (n_step, t_start, t_end) for
%                  each step
%               activeTaxels - the taxels activated during the trial
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

%% Unpack data
ftipRaw = data.ftipRaw;
nano = data.nano;
pos = data.pos;


% %% Start at time 0
% nano(:, 1) = nano(:, 1) - ftipRaw(1, 1);
% pos(:, 1) = pos(:, 1) - ftipRaw(1, 1);
% ftipRaw(:, 1) = ftipRaw(:, 1) - ftipRaw(1, 1);
% nano = nano(nano(:, 1) > 0, :);
% pos = pos(pos(:, 1) > 0, :);


%% Truncate time series
% Take latest starting time series as time 0
[lastStart, lastIndex] = max([ftipRaw(1, 1), nano(1, 1), pos(1, 1)]);
if (lastIndex == 1)         % ftip time series starts latest
    nano = nano(nano(:, 1) >= lastStart, :);
    pos = pos(pos(:, 1) >= lastStart, :);
elseif (lastIndex == 2)     % nano17 time series starts latest
    ftipRaw = ftipRaw(ftipRaw(:, 1) >= lastStart, :);
    pos = pos(pos(:, 1) >= lastStart, :);
elseif (lastIndex == 3)     % position time series starts latest
    ftipRaw = ftipRaw(ftipRaw(:, 1) >= lastStart, :);
    nano = nano(nano(:, 1) >= lastStart, :);
end
clear lastStart lastIndex;
% Take earliest ending time series as time end
[earlyEnd, earlyIndex] = min([ftipRaw(end, 1), nano(end, 1), pos(end, 1)]);
if (earlyIndex == 1)         % ftip time series starts latest
    nano = nano(nano(:, 1) <= earlyEnd, :);
    pos = pos(pos(:, 1) <= earlyEnd, :);
elseif (earlyIndex == 2)     % nano17 time series starts latest
    ftipRaw = ftipRaw(ftipRaw(:, 1) <= earlyEnd, :);
    pos = pos(pos(:, 1) <= earlyEnd, :);
elseif (earlyIndex == 3)     % position time series starts latest
    ftipRaw = ftipRaw(ftipRaw(:, 1) <= earlyEnd, :);
    nano = nano(nano(:, 1) <= earlyEnd, :);
end

%% Find closest timestamps
% Nano17 data
[~, indexes] = histc(ftipRaw(:, 1), nano(:, 1));
alNano = nano(indexes(indexes > 0), :);
clear indexes;
% Position data
[~, indexes] = histc(ftipRaw(:, 1), pos(:, 1));
alPos = pos(indexes(indexes > 0), :);
clear indexes;

% oldj = 0;
% oldk = 0;
% for i = 1:size(ftipRaw, 1)
%     [~, j] = min(abs(nano(oldj+1:end, 1) - ftipRaw(i, 1)));
%     alNano(i, :) = nano(oldj+j, :);
%     [~, k] = min(abs(pos(oldk+1:end, 1) - ftipRaw(i, 1)));
%     alPos(i, :) = pos(oldk+k, :);
%     oldj = j;
%     oldk = k;
% end


%% Build output structure
% Copy input data structure
fields = fieldnames(data);
for i = 1:numel(fields)
    res.(fields{i}) = data.(fields{i});
end
% Replace necessary fields
res.ftipRaw = ftipRaw;
res.nano = alNano;
res.pos = alPos;


end

