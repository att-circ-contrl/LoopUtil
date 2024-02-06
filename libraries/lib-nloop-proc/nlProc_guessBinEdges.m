function edges = nlProc_guessBinEdges(datavals, maxbins)

% function edges = nlProc_guessBinEdges(datavals, maxbins)
%
% This applies black magic to get a reasonable set of bin edges for a
% data series.
%
% The inter-quartile range is computed (with n/2 samples in that range), and
% bin size is chosen such that there are sqrt(n/2) bins in the IQR, rounded
% to an odd number. Bins are extended out to the inter-decile range.
%
% The resulting bins are intended to be useful for statistical analysis.
% For plotting, manual binning tends to look better.
%
% "datavals" is the series to define bins for.
% "maxbins" is the maximum number of bins to define. If omitted or NaN,
%   this defaults to 250. This number is approximate.
%
% "edges" is an array of bin edges, spanning the inter-decile range.


% Check optional arg for maximum bin count.

if ~exist('maxbins', 'var')
  maxbins = NaN;
end

if isnan(maxbins) || isempty(maxbins)
  maxbins = 250;
end


% Get input series statistics.

sampcount = length(datavals);

scratch = prctile(datavals, [ 10 25 75 90 ]);
lo10 = scratch(1);
lo25 = scratch(2);
hi25 = scratch(3);
hi10 = scratch(4);


% Get the number of IQR bins.
% This gets rounded to the nearest positive odd number.

bincount = sqrt(0.5 * sampcount);

% Clamp the number of IRQ bins to half the requested maximum.
bincount = min(bincount, round(0.5 * maxbins));

% Round to the nearest positive odd value.
bincount = 1 + 2 * round(0.5 * (bincount - 1));
bincount = max(bincount, 1);


% Get starting and ending bin edge indices.
% x_k = lo25 + k * step
% k(x) = (x - lo25) / step

binstep = (hi25 - lo25) / bincount;

% Handle the case where the inter-decile range is very much larger than IQR.
% This can happen if we have a narrow peak and wide noise floor.
if (hi10 - lo10) > (10 * (hi25 - lo25))
  binstep = (hi10 - lo10) / bincount;
end

% Handle failure cases.
% FIXME - Hardcoding "smallest reasonable case" values.
if 1.0e-20 > binstep
  binstep = (hi10 - lo10) / bincount;
end
if 1.0e-20 > binstep
  binstep = (max(datavals) - min(datavals)) / bincount;
end
if 1.0e-20 > binstep
  binstep = 1.0e-20;
end

kfirst = floor((lo10 - lo25) / binstep);
klast = ceil((hi10 - lo25) / binstep);

% Handle failure cases.
if isnan(kfirst) || isnan(klast) || (kfirst >= klast)
  kfirst = 0;
  klast = 1;
end


% Get the edge array. This is aligned with the quartile boundaries.

edges = kfirst:klast;

% FIXME - Sanity. We can get NaN percentile values under some conditions.
if (~isnan(binstep)) && (~isnan(lo25))
  edges = (edges * binstep) + lo25;
end


% Done.

end

%
% This is the end of the file.
