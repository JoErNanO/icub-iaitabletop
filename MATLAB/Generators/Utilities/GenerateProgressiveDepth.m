function [ res ] = GenerateProgressiveDepth(start, nSteps, increment)
%GENERATEPOSLIST Summary of this function goes here
%   Detailed explanation goes here


%% Create output
res = zeros(1 + nSteps*2, 1);

%% Increment depths
%res(1) = start;
res(1:nSteps+1) = start:increment:start+(increment*nSteps);
res(nSteps+2:end) = sort(start:increment:start+(increment*(nSteps - 1)), 'descend');


end

