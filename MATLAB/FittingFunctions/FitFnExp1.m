function [ y ] = FitFnExp1( x )
%FitFnExp1 Computes the Exponential1 of the given input.
%   The Exponential1 is computed as 
%       y(x) = a * (e ^ (x * b))
%   
%   where a and b are function parameters defined in the
%   "FittingModelExp1.mat" file.
%
%   INPUT:
%           x - m-by-1 vector of x values
%
%   OUTPUT:
%           y - m-by-1 vector of computed y values where y(x) = a * (e ^ (x * b))
%

%% Parameters
filename = 'FittingModelExp1.mat';

%% Load function parameters
if exist(filename, 'file')
    load(filename);
else
    error('FitFnExp1:LoadModel', ['Could not find the stored fitting model file "', filename, '".']);
end


%% Compute y
y = fm(x);

end

