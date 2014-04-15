function [ y ] = FitFnPower2( x )
%FitFnPower2 Computes the Power2 of the given input.
%   The Power2 is computed as 
%       y(x) = a * (x ^ b) + c
%   
%   where a, b and c are function parameters defined in the
%   "FittingModelPower2.mat" file.
%
%   INPUT:
%           x - m-by-1 vector of x values
%
%   OUTPUT:
%           y - m-by-1 vector of computed y values where y(x) = a * (x ^ b) + c
%


%% Parameters
filename = 'FittingModelPower2.mat';

%% Load function parameters
if exist(filename, 'file')
    load(filename);
else
    error('FitFnPower2:LoadModel', ['Could not find the stored fitting model file "' , filename, '".']);
end


%% Compute y
y = fm(x);

end

