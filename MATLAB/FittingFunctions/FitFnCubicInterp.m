function [ y ] = FitFnCubicInterp( x )
%FitFnCubicInterp Computes the Cubic Interpolant of the given input.
%   The Cubic Interpolant is computed as a piecewise polynomial computed 
%   from a coefficient structure.
%
%   The polynomial model is stored in the "FittingModelCubicinterp.mat"
%   file.
%
%   INPUT:
%           x - m-by-1 vector of x values
%
%   OUTPUT:
%           y - m-by-1 vector of computed y values where y(x) =
%           LinearInterpolant(x)
%

%% Parameters
filename = 'FittingModelCubicinterp.mat';

%% Load function parameters
if exist(filename, 'file')
    load(filename);
else
    error('FitFnCubicInterp:LoadModel', ['Could not find the stored fitting model file "', filename, '".']);
end


%% Compute y
y = fm(x);

end

