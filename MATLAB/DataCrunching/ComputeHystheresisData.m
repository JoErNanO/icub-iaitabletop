% Compute the data for hystheresis plot
function [res] = ComputeHystheresisData(data, expvals)
%ComputeHystheresisData Computes the means and standard deviations for the
%first and last second of each progressive depth experiment step.
%
% INPUT:
%           data - m-by-n array of data points
%
%           expvals - s-by-4 array of experiment steps descriptors
%
%
% OUTPUT:
%           res - structure with fields:
%               meanvals.first - n-by-1 array of mean values for the first
%                   second of each step
%               meanvals.last - n-by-1 array of mean values for the last
%                   second of each step
%               stdvals.first - n-by-1 array of std values for the first
%                   second of each step
%               stdvals.last - n-by-1 array of std values for the last
%                   second of each step
%               where n is the number of experiment steps
%

%% Compute means of first and last second of tap
meanValsFirst = zeros(size(expvals, 1), size(data, 2));
meanValsLast = zeros(size(meanValsFirst));
stdValsFirst = zeros(size(meanValsFirst));
stdValsLast = zeros(size(meanValsFirst));
for i = 1:size(expvals, 1)
    % First second
    indexes = data(:, 1) > expvals(i, 3);                   % t > t_start
    indexes = indexes & (data(:, 1) <= expvals(i, 3) + 1);	% t <= t_start + 1
    meanValsFirst(i, :) = mean(data(indexes, :));
    stdValsFirst(i, :) = std(data(indexes, :));
    
    % Last second
    indexes = data(:, 1) >= expvals(i, 4) - 1;          % t >= t_end - 1               
    indexes = indexes & (data(:, 1) < expvals(i, 4));     % t < t_end    
    meanValsLast(i, :) = mean(data(indexes, :));
    stdValsLast(i, :) = std(data(indexes, :));
end


%% Build result structure
res.meanvals.first = meanValsFirst;
res.meanvals.last = meanValsLast;
res.stdvals.first = stdValsFirst;
res.stdvals.last = stdValsLast;

end