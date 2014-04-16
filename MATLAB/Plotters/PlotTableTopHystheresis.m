function PlotTableTopHystheresis(figN, data, varargin)
%PLOTTABLETOPHystheresis Plots the fingertip skin sensor against the
%Nano17 force/torque data to show the skin sensor hystheresis.


%% Extract data structure
% Data
nanovals = data.nano;
ftipvalsRaw = data.ftipRaw;
posvals = data.pos;
expvals = data.exp;
robotName = data.robot;
baselines = data.baselines;
% Plot parameters
fzIndex = data.fzIndex;
posIndex = find(std(posvals(:, 2:end)) ~= 0) + 1;


%% Extract variable input args
% Build parser
p = inputParser;
% Plot visibility
defaultVis = 'on';
validVis = {defaultVis, 'off'};
checkVis = @(x) any(validatestring(x, validVis));
addOptional(p, 'Visible', defaultVis, checkVis);
% Plot type
defaultPlot = 'nano';
validPlot = {defaultPlot, 'pos'};
checkPlot = @(x) any(validatestring(x, validPlot));
addOptional(p, 'Plot', defaultPlot, checkPlot);
% Parse
parse(p, varargin{:});


%% Preprocess the data
% Remove baseline from nano17
nanovals(:, 2:end) = bsxfun(@minus, nanovals(:, 2:end), baselines{2});
% Remove baseline from pos
posvals(:, 2:end) = bsxfun(@minus, posvals(:, 2:end), baselines{3});

% Find active taxels
activeTaxels = data.activeTaxels;

% % Start at time 0
% nanovals(:, 1) = nanovals(:, 1) - nanovals(1, 1);
% ftipvalsRaw(:, 1) = ftipvalsRaw(:, 1) - ftipvalsRaw(1, 1);


%% Compute plot data
% Y Axis data
histYAxisVals = ComputeHystheresisData(ftipvalsRaw, expvals);
% Extract structures
meanFirstFtip = histYAxisVals.meanvals.first(2:end-1, activeTaxels);
meanLastFtip = histYAxisVals.meanvals.last(2:end-1, activeTaxels);
stdFirstFtip = histYAxisVals.stdvals.first(2:end-1, activeTaxels);
stdLastFtip = histYAxisVals.stdvals.last(2:end-1, activeTaxels);

% X Axis data
if strcmpi(p.Results.Plot, 'nano')
    histXAxisVals = ComputeHystheresisData(nanovals, expvals);
    meanFirstXAxis = histXAxisVals.meanvals.first(2:end-1, fzIndex);
    meanLastXAxis = histXAxisVals.meanvals.last(2:end-1, fzIndex);
    xLabel = 'Force (N)';
elseif strcmpi(p.Results.Plot, 'pos')
    histXAxisVals = ComputeHystheresisData(posvals, expvals);
    meanFirstXAxis = histXAxisVals.meanvals.first(2:end-1, posIndex) / 1000;
    meanLastXAxis = histXAxisVals.meanvals.last(2:end-1, posIndex) / 1000;
    xLabel = 'Position (mm)';
end



%% Generate color map
colors = distinguishable_colors(20);


%% Plot the data
figName = ['TableTop fingertip and nano17 sensor results for trial n. ', data.trial];
figure(figN);
set(figN, 'Name', figName);
set(figN, 'DefaultAxesColorOrder', colors);
set(figN, 'Visible', p.Results.Visible)
clf;

fontsize = 20;


%% Plot hystheresis graphs - 1st and 60th second of press
% First second of tap
subplot(2, 1, 1);
hold on
% plot(histNanovals.meanvals.first(2:end-1, fzIndex), histFtipvals.meanvals.first(2:end-1, activeTaxels), 'b');
% errorbar(histNanovals.meanvals.first(2:end-1, fzIndex), histFtipvals.meanvals.first(2:end-1, activeTaxels), histFtipvals.stdvals.first(2:end-1, activeTaxels), 'b');
errorbar(meanFirstXAxis, meanFirstFtip, stdFirstFtip);
xlim([min(meanFirstXAxis(:, 1))-0.05 max(meanFirstXAxis(:, 1))+0.05]);
% Legend labels
labels = cell(12, 1);
for i = 1:size(labels, 1)
    labels{i} = ['Taxel ', int2str(i), ' - First Second'];
end
legend(labels{activeTaxels-1}, 'Location', 'SouthEast');
hold off

set(gca, 'YDir', 'reverse');
set(gca, 'XDir', 'reverse');

title(['\bf{Nano17 Force} \rm{vs.} \bf{skin} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'], 'FontSize', fontsize);
ylabel('Raw Skin', 'FontSize', fontsize);
xlabel(xLabel, 'FontSize', fontsize);

% Last second of tap
subplot(2, 1, 2);
hold on
% plot(histNanovals.meanvals.last(2:end-1, fzIndex), histFtipvals.meanvals.last(2:end-1, activeTaxels), 'g');
% errorbar(histNanovals.meanvals.last(2:end-1, fzIndex), histFtipvals.meanvals.last(2:end-1, activeTaxels), histFtipvals.stdvals.last(2:end-1, activeTaxels), 'g');
errorbar(meanLastXAxis, meanLastFtip, stdLastFtip);
xlim([min(meanLastXAxis(:, 1))-0.02 max(meanLastXAxis(:, 1))+0.02]);
% Legend labels
labels = cell(12, 1);
for i = 1:size(labels, 1)
    labels{i} = ['Taxel ', int2str(i), ' - Last Second'];
end
legend(labels{activeTaxels-1}, 'Location', 'SouthEast');
hold off

set(gca, 'YDir', 'reverse');
set(gca, 'XDir', 'reverse');

title(['\bf{Nano17 Force} \rm{vs.} \bf{skin} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'], 'FontSize', fontsize);
ylabel('Raw Skin', 'FontSize', fontsize);
xlabel(xLabel, 'FontSize', fontsize);


end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the data for hystheresis plot
function [res] = ComputeHystheresisData(data, expvals)
%ComputeHystheresisData Computes the means and standard deviations for the
%first and last second of each progressive depth experiment step.
%
% OUTPUT:
%           res - structure with fields:
%               meanvals.first - n-by-1 array of mean values for the first
%                   second of each step
%               meanvals.last - n-by-1 array of mean values for the last
%                   second of each step
%               stdvals.first - n-by-1 array of std values for the first
%                   second of each step
%               stdvals.last - n-by-1 array of std values for the last
%                   second of each step
%               where n is the number of experiment steps
%

%% Compute means of first and last second of tap
meanValsFirst = zeros(size(expvals, 1), size(data, 2));
meanValsLast = zeros(size(meanValsFirst));
stdValsFirst = zeros(size(meanValsFirst));
stdValsLast = zeros(size(meanValsFirst));
for i = 1:size(expvals, 1)
    % First second
    indexes = data(:, 1) > expvals(i, 3);                   % t > t_start
    indexes = indexes & (data(:, 1) <= expvals(i, 3) + 1);	% t <= t_start + 1
    meanValsFirst(i, :) = mean(data(indexes, :));
    stdValsFirst(i, :) = std(data(indexes, :));
    
    % Last second
    indexes = data(:, 1) >= expvals(i, 4) - 1;          % t >= t_end - 1               
    indexes = indexes & (data(:, 1) < expvals(i, 4));     % t < t_end    
    meanValsLast(i, :) = mean(data(indexes, :));
    stdValsLast(i, :) = std(data(indexes, :));
end


%% Build result structure
res.meanvals.first = meanValsFirst;
res.meanvals.last = meanValsLast;
res.stdvals.first = stdValsFirst;
res.stdvals.last = stdValsLast;

end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%