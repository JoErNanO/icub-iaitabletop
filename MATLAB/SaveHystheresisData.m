function [res] = SaveHystheresisData(trialRange, varargin)
%SAVEHYSTHERESISDATA Summary of this function goes here
%   Detailed explanation goes here


%% Prelocate data to be saved
dataYAxis = cell(numel(trialRange), 1);
dataXAxis = cell(numel(trialRange), 1);


%% Load trial data

for i = 1:numel(trialRange)
    trial = trialRange(i);
    
    %% Load data
    fprintf(['Loading data for trial n. ', num2str(trial), '. \n']);
    tmpData = LoadTableTopData(trial, 'Filter', 'on');
    fprintf('Done. \n');
    
    %% Preprocess the data
%     % Remove baseline from Y Axis
%     tmpData.ftipRaw(:, 2:end) = bsxfun(@minus, tmpData.ftipRaw(:, 2:end), tmpData.baselines{1});
    % Remove baseline from X Axis
    tmpData.nano(:, 2:end) = bsxfun(@minus, tmpData.nano(:, 2:end), tmpData.baselines{2});  

    %% Compute hystheresis data
    fprintf(['Computing data for trial n. ', num2str(trial), '. \n']);
    tmpYAxisData = ComputeHystheresisData(tmpData.ftipRaw, tmpData.exp);
    tmpXAxisData = ComputeHystheresisData(tmpData.nano, tmpData.exp);
    
    %% Extract data
    % Y Axis
    meanFirstFtip = tmpYAxisData.meanvals.first(2:end-1, tmpData.activeTaxels);
    meanLastFtip = tmpYAxisData.meanvals.last(2:end-1, tmpData.activeTaxels);
    stdFirstFtip = tmpYAxisData.stdvals.first(2:end-1, tmpData.activeTaxels);
    stdLastFtip = tmpYAxisData.stdvals.last(2:end-1, tmpData.activeTaxels);
    % X Axis
    meanFirstXAxis = repmat(tmpXAxisData.meanvals.first(2:end-1, tmpData.fzIndex), 1, size(meanFirstFtip, 2));
    meanLastXAxis = repmat(tmpXAxisData.meanvals.last(2:end-1, tmpData.fzIndex), 1, size(meanFirstFtip, 2));
    
    %% Fill in data structure to be saved
    % Y Axis
    dataYAxis{i}.muStart = meanFirstFtip;
    dataYAxis{i}.muEnd = meanLastFtip;
    dataYAxis{i}.stdStart = stdFirstFtip;
    dataYAxis{i}.stdEnd = stdLastFtip;
    % X Axis
    dataXAxis{i}.muStart = meanFirstXAxis;
    dataXAxis{i}.muEnd = meanLastXAxis;
    
    fprintf('Done. \n');
end


%% Save data
fprintf('Saving data. \n');
res.dataYAxis = dataYAxis;
res.dataXAxis = dataXAxis;
save('Data/Hystheresis.mat', 'dataYAxis', 'dataXAxis');
fprintf('Done. \n');


end

