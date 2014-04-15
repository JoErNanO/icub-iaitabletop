function [ y ] = FitFnPower1( x )
%FitFnPower1 Computes the Power1 of the given input.
%   The Power2 is computed as 
%       y(x) = a * (x ^ b)
%   
%   where a and b are function parameters defined in the
%   "FittingModelPower1.mat" file.
%
%   INPUT:
%           x - m-by-1 vector of x values
%
%   OUTPUT:
%           y - m-by-1 vector of computed y values where y(x) = a * (x ^ b)
%


%% Parameters
filename = 'FittingModelPower1.mat';

%% Load function parameters
if exist(filename, 'file')
    load(filename);
else
    error('FitFnPower1:LoadModel', ['Could not find the stored fitting model file "' , filename, '".']);
end


%% Compute y
y = fm(x);

end

