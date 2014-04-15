function [res] = GenerateFittingModels()
%GENERATEFITTINGMODELS Summary of this function goes here
%   Detailed explanation goes here


%% Load fingertip profile
filename = 'ftipprofile2.mat';
if exist(filename, 'file')
    load(filename)
else
    error('GenerateFittingModels:LoadFtipProfile', ['Could not find the stored fingertip profile file "', filename, '".']);
end


%% Transform data
% Converto to 10^-3mm (um)
y = y * 1000;
x = x * 1000;
% Shift and compute symmetry
y = -y + max(y);

%% Generate fitting models
% List of available models
models = cell(5, 1);
models{1} = 'exp1';
models{2} = 'exp2';
models{3} = 'linearinterp';
models{4} = 'cubicinterp';
models{5} = 'power1';
models{6} = 'power2';

% Generate models
res = cell(size(models, 1), 1);
for i = 1:size(res, 1)
    modelname = models{i};
    try
        fm = fit(x', y', modelname);
        save(['MatFiles/FittingModel', upper(modelname(1)), modelname(2:end), '.mat'], 'fm');
        res{i} = fm;
    catch err
        if (strcmp(err.identifier,'curvefit:fit:powerFcnsRequirePositiveData'))
            err
        else
            rethrow(err);
        end
    end
end


end

