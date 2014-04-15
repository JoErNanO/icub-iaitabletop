function PlotTableTopHystheresis(figN, data, varargin)
%PLOTTABLETOPHystheresis Plots the fingertip skin sensor against the
%Nano17 force/torque data to show the skin sensor hystheresis.


%% Extract data structure
nanovals = data.nano;
ftipvalsRaw = data.ftipRaw;
expvals = data.exp;
robotName = data.robot;


%% Extract variable input args
% Build parser
p = inputParser;
defaultVis = 'on';
validVis = {'on', 'off'};
checkVis = @(x) any(validatestring(x, validVis));
addOptional(p, 'Visible', defaultVis, checkVis);
% Parse
parse(p, varargin{:});


%% Preprocess the data
% Remove baseline from nano17
j = find(nanovals(:,1) > 15, 1);
if ~isempty(j)
    for i = 2:size(nanovals, 2)
        nanovals(:, i) = nanovals(:, i) - nanovals(j, i);
    end
end

% Find active taxels
activeTaxels = data.activeTaxels;

% % Start at time 0
% nanovals(:, 1) = nanovals(:, 1) - nanovals(1, 1);
% ftipvalsRaw(:, 1) = ftipvalsRaw(:, 1) - ftipvalsRaw(1, 1);


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
% Plot parameters
fzIndex = data.fzIndex;

% Compute plot data
histFtipvals = ComputeHystheresisData(ftipvalsRaw, expvals);
histNanovals = ComputeHystheresisData(nanovals, expvals);
% Extract structures
meanFirstFtip = histFtipvals.meanvals.first(2:end-1, activeTaxels);
meanLastFtip = histFtipvals.meanvals.last(2:end-1, activeTaxels);
stdFirstFtip = histFtipvals.stdvals.first(2:end-1, activeTaxels);
stdLastFtip = histFtipvals.stdvals.last(2:end-1, activeTaxels);
meanFirstNano = repmat(histNanovals.meanvals.first(2:end-1, fzIndex), 1, size(meanFirstFtip, 2));
meanLastNano = repmat(histNanovals.meanvals.last(2:end-1, fzIndex), 1, size(meanFirstFtip, 2));

% First second of tap
subplot(2, 1, 1);
hold on
% plot(histNanovals.meanvals.first(2:end-1, fzIndex), histFtipvals.meanvals.first(2:end-1, activeTaxels), 'b');
% errorbar(histNanovals.meanvals.first(2:end-1, fzIndex), histFtipvals.meanvals.first(2:end-1, activeTaxels), histFtipvals.stdvals.first(2:end-1, activeTaxels), 'b');
errorbar(meanFirstNano, meanFirstFtip, stdFirstFtip);
xlim([min(meanFirstNano(:, 1))-0.1 max(meanFirstNano(:, 1))+0.1]);
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
xlabel('Force (N)', 'FontSize', fontsize);

% Last second of tap
subplot(2, 1, 2);
hold on
% plot(histNanovals.meanvals.last(2:end-1, fzIndex), histFtipvals.meanvals.last(2:end-1, activeTaxels), 'g');
% errorbar(histNanovals.meanvals.last(2:end-1, fzIndex), histFtipvals.meanvals.last(2:end-1, activeTaxels), histFtipvals.stdvals.last(2:end-1, activeTaxels), 'g');
errorbar(meanLastNano, meanLastFtip, stdLastFtip);
xlim([min(meanLastNano(:, 1))-0.1 max(meanLastNano(:, 1))+0.1]);
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
xlabel('Force (N)', 'FontSize', fontsize);


end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the data for hystheresis plot
function [res] = ComputeHystheresisData(data, expvals)
%ComputeHystheresisData Computes the means and standard deviations for the
%first and last second of each progressive depth experiment step.

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