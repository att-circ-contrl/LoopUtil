function [ firstsampmask secondsampmask ] = ...
  nlUtil_getCommonTimeRanges( firsttimes, secondtimes )

% function [ firstsampmask secondsampmask ] = ...
%   nlUtil_getCommonTimeRanges( firsttimes, secondtimes )
%
% This accepts two ascending-sorted series and finds the span of samples
% within each that cover overlapping value ranges.
%
% This is mostly used to find time-aligned subsets of two series using
% timestamp values.
%
% "firsttimes" is a vector of timestamp values in ascending order.
% "secondtimes" is a vector of timestamp values in ascending order.
%
% "firstsampmask" is a mask vector tha's true for samples in "firsttimes"
%   that have values within the minimum and maximum range of both input series.
% "secondsampmask" is a mask vector tha's true for samples in "secondtimes"
%   that have values within the minimum and maximum range of both input series.


sharedmin = max( min(firsttimes), min(secondtimes) );
sharedmax = min( max(firsttimes), max(secondtimes) );

firstsampmask = (firsttimes >= sharedmin) & (firsttimes <= sharedmax);
secondsampmask = (secondtimes >= sharedmin) & (secondtimes <= sharedmax);


% Done.
end


%
% This is the end of the file.
