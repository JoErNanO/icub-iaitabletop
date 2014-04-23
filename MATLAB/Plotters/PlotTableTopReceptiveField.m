function PlotTableTopReceptiveField(figN, data, varargin)
%PLOTTABLETOPRECEPTIVEFIELD Plots the data from the receptive field
%experiments.

%% Extract data structure
ftipvalsRaw = data.ftipRaw;
nanovals = data.nano;
posvals = data.pos;
robotName = data.robot;
activeTaxels = data.activeTaxels;
% Plot parameters
fzIndex = data.fzIndex;
posYIndex = data.posYIndex;


%% Extract variable input args
% Build parser
p = inputParser;
defaultVis = 'on';
validVis = {'on', 'off'};
checkVis = @(x) any(validatestring(x, validVis));
addOptional(p, 'Visible', defaultVis, checkVis);
% Parse
parse(p, varargin{:});


%% Preprocess data
% Start at y_0 == 0
posvals(:, posYIndex) = posvals(:, posYIndex) - max(posvals(:, posYIndex));
posvals(:, posYIndex) = abs(posvals(:, posYIndex) - max(posvals(:, posYIndex)));


%% Filter out data
ranges = zeros(2, size(nanovals, 2));
meanval = mean(nanovals(:, fzIndex));
ranges(1, 4) = meanval - abs(meanval / 4);
ranges(2, 4) = meanval + abs(meanval / 4);
% ranges(1, 4) = -1;
% ranges(2, 4) = -0.1;
indexes = FilterOutData(nanovals, ranges);


%% Compute plot data
tmp.pos = posvals(indexes(:, fzIndex), posYIndex);
tmp.ftipRaw = ftipvalsRaw(indexes(:, fzIndex), :);      % FG: Use all data to avoid having to do activeTaxels-1 when plotting
plotdata = ComputeReceptiveFieldData(tmp);
meanvals = plotdata.mean;
stdvals = plotdata.std;
posvals = plotdata.pos;
posvals = posvals / 1000;
clear tmp;


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

errorbar(repmat(posvals, 1, numel(activeTaxels)), meanvals(:, activeTaxels), stdvals(:, activeTaxels));
% Axes
axis tight;
title(['\bf{Skin Comp} \rm{values for trial n.} ', data.trial, ' (', robotName, ')'], 'FontSize', fontsize);
xlabel('Position (mm)', 'FontSize', fontsize)
ylabel('Sensor value', 'FontSize', fontsize);
% Legend labels
labels = cell(12, 1);
for i = 1:size(labels, 1)
    labels{i} = ['Taxel ', int2str(i)];
end
legend(labels{activeTaxels-1}, 'Location', 'SouthEast');
% Invert axes
set(gca, 'YDir', 'reverse');
% set(gca, 'XDir', 'reverse');


end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the data for the Receptive field plot.
function [res] = ComputeReceptiveFieldData(data)
%COMPUTERECEPTIVEFIELDDATA Computes the mean and standard deviation for
%each Y position step during a receptive field experiment.


%% Extract data structure
posvals = data.pos;
ftipvalsRaw = data.ftipRaw;

%% Find unique y position values
positions = unique(posvals, 'stable');

%% Compute means and std
meanvals = zeros(numel(positions), size(ftipvalsRaw, 2));
stdvals = zeros(size(meanvals));
for i = 1:numel(positions)
    % Find first and last data index
    startI = find(posvals == positions(i), 1);
    endI = find(posvals == positions(i), 1, 'last');
    
    % Compute mean and std
    if endI-startI > 0
        meanvals(i, :) = mean(ftipvalsRaw(startI:endI, :));
        stdvals(i, :) = std(ftipvalsRaw(startI:endI, :));
    else
        meanvals(i, :) = ftipvalsRaw(startI:endI, :);
        stdvals(i, :) = 0;
    end
        
end

%% Build result structure
res.mean = meanvals;
res.std = stdvals;
res.pos = positions;

end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

