function [res] = FilterOutData(data, ranges)
%FILTEROUTDATA Filters the given data by taking only the values which fall
%in the supplied ranges. Data is filtered out if it falls into the interval
%[ranges.min ranges.max].
%
%
% Input:
%
%       data - m-by-n matrix of data points
%
%       ranges - 2-by-n matrix of ranges where the first row are the lower
%           and the second row are the higher bounds of the ranges
%
%
% Output:
%
%       res - p-by-n matrix of filtered data
%

%% Find indexes of filtered data
minranges = repmat(ranges(1, :), size(data, 1), 1);
maxranges = repmat(ranges(2, :), size(data, 1), 1);
indexes = (data >= minranges) & (data <= maxranges);

res = indexes;
% %% Get filtered data
% res = data(indexes);


end

