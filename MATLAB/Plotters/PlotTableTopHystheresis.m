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
% posIndex = find(std(posvals(:, 2:end)) ~= 0) + 1;
posIndex = fzIndex;


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
    meanFirstXAxis = repmat(histXAxisVals.meanvals.first(2:end-1, fzIndex), 1, size(meanFirstFtip, 2));
    meanLastXAxis = repmat(histXAxisVals.meanvals.last(2:end-1, fzIndex), 1, size(meanFirstFtip, 2));
    
    figName = ['TableTop fingertip and nano17 sensor results for trial n. ', data.trial];
    plotTitle = ['\bf{Force} \rm{vs.} \bf{skin} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'];
    xLabel = 'Force (N)';
elseif strcmpi(p.Results.Plot, 'pos')
    histXAxisVals = ComputeHystheresisData(posvals, expvals);
    meanFirstXAxis = repmat(histXAxisVals.meanvals.first(2:end-1, posIndex) / 1000, 1, size(meanFirstFtip, 2));
    meanLastXAxis = repmat(histXAxisVals.meanvals.last(2:end-1, posIndex) / 1000, 1, size(meanFirstFtip, 2));
    
    figName = ['TableTop fingertip and position results for trial n. ', data.trial];
    plotTitle = ['\bf{Force} \rm{vs.} \bf{position} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'];
    xLabel = 'Position (mm)';
end



%% Generate color map
colors = distinguishable_colors(20);


%% Plot the data
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
if strcmpi(p.Results.Plot, 'nano')
    set(gca, 'XDir', 'reverse');
end

title(plotTitle, 'FontSize', fontsize);
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
if strcmpi(p.Results.Plot, 'nano')
    set(gca, 'XDir', 'reverse');
end

title(plotTitle, 'FontSize', fontsize);
ylabel('Raw Skin', 'FontSize', fontsize);
xlabel(xLabel, 'FontSize', fontsize);


end