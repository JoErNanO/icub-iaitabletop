function [data, alData] = PlotTableTopAll(trialRange, trialType, varargin)
%PLOTTABLETOPALL Plots all the tabletop experiment results for the given
%trial number range.
%
% Input:
%
%       trialRange - the range of trials. Can be either a single trial or a
%                   vector in the form start:end (for example 2:4)
%
%       trialType - string representing the type of trial. Accepted values are 'progdepth',
%           'recfield'.
%


%% Extract varargin
% Spike filtering
varargLoad = ExtractVarargin(varargin, 'Filter');
% Plot visibility
varargPlot = ExtractVarargin(varargin, 'Visible');
% Position axis to plot
varargPlotPos = [varargPlot{:}, ExtractVarargin(varargin, 'PosAxis')];



for trial = trialRange(1):trialRange(end)
    %% Load data
    fprintf(['Loading data for trial n. ' num2str(trial), '. \n']);
    data = LoadTableTopData(trial, varargLoad{:});
    fprintf('Done. \n');

    fprintf('Aligning the timestamped data. \n');
    alData = AlignTimestamps(data);
    fprintf('Done. \n');


    %% Call plots
    fprintf('Plotting results. \n');
    if strcmp(trialType, 'progdepth')
        PlotTableTopSkinNano17(1, alData, varargPlot{:});
        PlotTableTopHystheresis(2, alData, varargPlot{:}, 'Plot', 'nano');
        PlotTableTopHystheresis(3, alData, varargPlot{:}, 'Plot', 'pos');
        PlotTableTopSkinPosition(4, alData, varargPlotPos{:});
    elseif strcmp(trialType, 'recfield')
        PlotTableTopSkinNano17(1, alData, varargPlot{:});
        PlotTableTopReceptiveField(2, alData, varargPlot{:});
    else
        error('PlotTableTopAll:UnknownTrialType', ['Cannot plot data for the specified trial type: ', trialType, '.']);
    end
    fprintf('Done. \n');
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract varargin
function [res] = ExtractVarargin(paramlist, paramval)


% Find index of param
ind = find(strcmp(paramlist, paramval));
if isempty(ind)
    error('PlotTableTopAll:UnknownParameter', ['The input parameter ', paramval, 'is invalid.']);
else
    res = paramlist(ind:ind + 1);
end

end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%