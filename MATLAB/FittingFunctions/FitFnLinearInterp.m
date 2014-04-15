function [ y ] = FitFnLinearInterp( x )
%FitFnLinearInterp Computes the Linear Interpolant of the given input.
%   The Linear Interpolant is computed as a piecewise polynomial computed 
%   from a coefficient structure.
%
%   The polynomial model is stored in the "FittingModelLinearinterp.mat"
%   file.
%
%
%   INPUT:
%           x - m-by-1 vector of x values
%
%   OUTPUT:
%           y - m-by-1 vector of computed y values where y(x) =
%           LinearInterpolant(x)
%

%% Parameters
filename = 'FittingModelLinearinterp.mat';

%% Load function parameters
if exist(filename, 'file')
    load(filename);
else
    error('FitFnLinearInterp:LoadModel', ['Could not find the stored fitting model file "', filename, '".']);
end


%% Compute y
y = fm(x);

end

