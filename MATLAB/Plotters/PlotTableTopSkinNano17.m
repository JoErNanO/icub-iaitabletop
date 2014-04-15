function PlotTableTopSkinNano17(figN, data, varargin)
%PLOTTABLETOPSKINNANO17 Plots the fingertip skin sensor and the
%Nano17 force/torque data against the sample timestamp.


%% Extract data structure
nanovals = data.nano;
ftipvalsRaw = data.ftipRaw;
posvals = data.pos;
robotName = data.robot;
baselines = data.baselines;


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
% Remove starting time from timestamp
nanovals(:, 1) = nanovals(:, 1) - nanovals(1, 1);
ftipvalsRaw(:, 1) = ftipvalsRaw(:, 1) - ftipvalsRaw(1, 1);
posvals(:, 1) = posvals(:, 1) - posvals(1, 1);

% Remove baseline from nano17
% j = find(nanovals(:, 1) > 15,1);
% if ~isempty(j)
%     for i = 1:size(nanovals,2)
%         nanovals(:, i) = nanovals(:, i) - nanovals(j, i);
%     end
% end

% Remove baseline from nano17
nanovals(:, 2:end) = bsxfun(@minus, nanovals(:, 2:end), baselines{2});

% Flip position values
posvals(:, 4) = -posvals(:, 4) + min(posvals(:, 4));
% Convert to mm
posvals(:, 2:end) = posvals(:, 2:end) ./ 1000;

% Find active taxels
activeTaxels = data.activeTaxels;


%% Generate color map
colors = distinguishable_colors(20);


%% Plot the data
% Plot parameters
fzIndex = data.fzIndex;

% Figure
figName = ['TableTop fingertip and nano17 sensor results for trial n. ', data.trial];
figure(figN);
set(figN, 'Name', figName);
set(figN, 'DefaultAxesColorOrder', colors);
set(figN, 'Visible', p.Results.Visible)
clf;

fontsize = 20;

% Plot skin data
subplot(2, 2, [1, 3]);
plot(ftipvalsRaw(:, 1), [ftipvalsRaw(:, activeTaxels), repmat(baselines{1}(activeTaxels-1), size(ftipvalsRaw(:, activeTaxels), 1), 1)]);
set(gca, 'OuterPosition', [0, 0, 0.5, 1])
axis tight;
title(['\bf{Skin Raw} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'], 'FontSize', fontsize);
xlabel('Time (s)', 'FontSize', fontsize)
ylabel('Sensor value', 'FontSize', fontsize);
% Legend
labels = cell(12, 1);
for i = 1:size(labels, 1)
    labels{i} = ['Taxel ', int2str(i)];
end
legend(labels{activeTaxels-1}, 'Location', 'SouthEast');

% Plot nano17 data
subplot(2, 2, 2);
plot(nanovals(:, 1), nanovals(:, fzIndex));
set(gca, 'OuterPosition', [0.5, 0.5, 0.5, 0.5])
axis tight;
title(['\bf{Nano17 Force} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'], 'FontSize', fontsize);
xlabel('Time (s)', 'FontSize', fontsize)
ylabel('Force (N)', 'FontSize', fontsize);

% Plot position data
subplot(2, 2, 4);
plot(posvals(:, 1), posvals(:, 4), 'm');
set(gca, 'OuterPosition', [0.5, 0, 0.5, 0.5])
axis tight;
title(['\bf{Robot Position} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'], 'FontSize', fontsize);
xlabel('Time (s)', 'FontSize', fontsize)
ylabel('Position (mm)', 'FontSize', fontsize);


end

