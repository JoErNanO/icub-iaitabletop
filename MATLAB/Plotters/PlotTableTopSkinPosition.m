function PlotTableTopSkinPosition(figN, data, varargin)
%PLOTTABLETOPSKINPOSITION Plots the fingertip skin sensor against the robot
%position.

%% Extract data structure
ftipvalsRaw = data.ftipRaw;
posvals = data.pos;
expvals = data.exp;
robotName = data.robot;
baselines = data.baselines;
% Find active taxels
activeTaxels = data.activeTaxels;


%% Extract variable input args
% Build parser
p = inputParser;
% Plot visibility
defaultVis = 'on';
validVis = {'on', 'off'};
checkVis = @(x) any(validatestring(x, validVis));
addOptional(p, 'Visible', defaultVis, checkVis);
% Position axis
defaultAxis = 'z';
validAxis = {'x', 'y', 'z'};
checkAxis = @(x) any(validatestring(x, validAxis));
addOptional(p, 'PosAxis', defaultAxis, checkAxis);
% Parse
parse(p, varargin{:});

% Convert axis into numbers
if strcmpi(p.Results.PosAxis, 'x')
    plotaxis = 1;
elseif strcmpi(p.Results.PosAxis, 'y')
    plotaxis = 2;
elseif strcmpi(p.Results.PosAxis, 'z')
    plotaxis = 3;
end


%% Preprocess the data
% Compute plot data
ftipvalsRaw = ComputePlotData(ftipvalsRaw, expvals);
posvals = ComputePlotData(posvals, expvals);

% Flip position values
% Find maximum
[m, ~] = max(posvals(:, plotaxis+1));
maxIndexes = [find(posvals(:, plotaxis+1) == m, 1, 'first'), find(posvals(:, plotaxis+1) == m, 1, 'last')];
indexes = zeros(size(posvals(:, plotaxis+1)));
% Compute to obtain a ---- o +++++ line centered on the maximum depth
indexes(1:maxIndexes(1)-1) = +1;
indexes(maxIndexes(2)+1:end) = -1;
plotdata = posvals(:, plotaxis+1);
plotdata = plotdata - m;
plotdata = plotdata .* indexes;
posvals(:, plotaxis+1) = plotdata;
clear plotdata indexes;

% Convert to mm
posvals(:, 2:end) = posvals(:, 2:end) ./ 1000;


%% Generate color map
colors = distinguishable_colors(20);


%% Plot the data
% Figure
figName = ['TableTop fingertip and nano17 sensor results for trial n. ', data.trial];
figure(figN);
set(figN, 'Name', figName);
set(figN, 'DefaultAxesColorOrder', colors);
set(figN, 'Visible', p.Results.Visible)
clf;

fontsize = 20;

% Plot skin vs position
plot(posvals(2:end-1, plotaxis+1), [ftipvalsRaw(2:end-1, activeTaxels), repmat(baselines{1}(activeTaxels-1), size(ftipvalsRaw(2:end-1, activeTaxels), 1), 1)], '.-  ');
axis tight;
title(['\bf{Skin Raw} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'], 'FontSize', fontsize);
xlabel('Position (mm)', 'FontSize', fontsize)
ylabel('Sensor value', 'FontSize', fontsize);
% Legend
labels = cell(12, 1);
for i = 1:size(labels, 1)
    labels{i} = ['Taxel ', int2str(i)];
end
legend(labels{activeTaxels-1}, 'Location', 'SouthEast');

end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the data for the plot
function [res] = ComputePlotData(data, expvals)

%% Compute mean values during experiment step
tmpRes = zeros(size(expvals, 1), size(data, 2));
for i = 1:size(tmpRes)
    % Find data indexes
    indexes = data(:, 1) >= expvals(i, 3);            % t >= t_i_start
    indexes = indexes & data(:, 1) <= expvals(i, 4);  % t <= t_i_end
    
    % Compute mean
    tmpRes(i, :) = mean(data(indexes, :));
end


%% Build result
% Filter out baseline step
% Filter out last step for histheresis time constant    
% res = tmpRes(2:end-1, :);
res = tmpRes;

end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
