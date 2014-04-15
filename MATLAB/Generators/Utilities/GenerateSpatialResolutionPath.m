function [ res ] = GenerateSpatialResolutionPath(path, depth)
%GENERATESPATIALRESOLUTIONPATH Summary of this function goes here
%   Detailed explanation goes here

%% Compute path steps
nPathSteps = path.length / path.increment;


%% Generate depth profile
depths = GenerateProgressiveDepth(depth.start, depth.steps, depth.increment);
paths = zeros(nPathSteps, 1);
for i = 1:nPathSteps
    if strcmp(path.direction, 'decr')
        paths(i) = path.start - (i-1)*path.increment;
    elseif strcmp(path.direction, 'incr')
        paths(i) = path.start + (i-1)*path.increment;
    else
        error('GenerateSpatialResolutionPath:UnknownPathDirection', ['Cannot generate the path in the given direction: "', path.direction, '".']);
    end
end


%% Initialise output
res = zeros(nPathSteps * size(depths, 1), 2);


%% Add coordinates
start = 1;
for i = 1:nPathSteps
    endd = start + size(depths, 1) - 1;
    res(start:endd, 1) = paths(i);
    res(start:endd, 2) = depths;
    start = endd + 1;
end

end

