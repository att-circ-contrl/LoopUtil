function [ sampfirst samplast ] = ...
  nlUtil_getTrimmedSampleSpan( samptotalcount, trim_fraction );

% function [ sampfirst samplast ] = ...
%   nlUtil_getTrimmedSampleSpan( samptotalcount, trim_fraction );
%
% This picks a sample span within the range [1..samptotalcount] that trims
% the specified fraction of samples from each end.
%
% Making this a function to guarantee consistent output between instances.
%
% "samptotalcount" is the length of the span of samples to take a subset from.
% "trim_fraction" (in the range 0 to 0.5) is the fraction of the total span
%   to trim from the start and end of the span.
%
% "sampfirst" is the index of the first sample kept.
% "samplast" is the index of the last sample kept.


% Force input sanity.

samptotalcount = round(samptotalcount);
samptotalcount = max(1, samptotalcount);

trim_fraction = max(0, trim_fraction);
trim_fraction = min(0.49, trim_fraction);


% Calculate the trimmed span.

trimlength = round(samptotalcount * trim_fraction);
sampfirst = 1 + trimlength;
samplast = samptotalcount - trimlength;


% Force output sanity; we can get overlap otherwise.

samplast = max(sampfirst, samplast);


% Done.
end


%
% This is the end of the file.
