function [ y ] = FitFnExp2( x )
%FitFnExp2 Computes the Exponential2 of the given input.
%   The Exponential1 is computed as 
%       y(x) = a * (e ^ (x * b)) + c * (e ^ (x * d))
%   
%   where a, b, c and d are function parameters defined in the
%   "FittingModelExp1.mat" file.
%
%   INPUT:
%           x - m-by-1 vector of x values
%
%   OUTPUT:
%           y - m-by-1 vector of computed y values where y(x) = a * (e ^ (x * b)) + c * (e ^ (x * d))
%

%% Parameters
filename = 'FittingModelExp2.mat';

%% Load function parameters
if exist(filename, 'file')
    load(filename);
else
    error('FitFnExp2:LoadModel', ['Could not find the stored fitting model file "', filename, '".']);
end


%% Compute y
y = fm(x);

end

