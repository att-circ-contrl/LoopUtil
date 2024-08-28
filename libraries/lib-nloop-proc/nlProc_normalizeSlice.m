function newmatrix = nlProc_normalizeSlice( oldmatrix, refmatrix, method )

% function newmatrix = nlProc_normalizeSlice( oldmatrix, refmatrix, method )
%
% This normalizes an n-dimensional matrix, z-scoring it with respect to a
% reference matrix (usually a subset of the input).
%
% This can be used stand-alone, but is intended to be used as a helper
% function to normalize slices of a higher-dimensional array (such as
% normalizing within each row or column of a matrix).
%
% Z-scoring may be via any of several methods:
%
% 'zscore' computes the mean and standard deviation and scales these to
%   zero and one, respectively.
% 'median' computes the median and IQR and scales these to zero and
%   1.34, respectively (giving a standard deviation of 1 for normal data).
% 'twosided' computes the median and upper and lower quartiles, shifing the
%   median to zero and scaling above- and below-median values separately so
%   that the quartiles are 0.67 (giving a standard deviation of 1 and
%   removing skew).
%
% "oldmatrix" is an n-dimensional matrix to normalize.
% "refmatrix" is an m-dimensional matrix to take statistics from. This is
%   usually either a copy of "oldmatrix" or a windowed subset of it.
% "method" is 'zscore', 'median', or 'twosided'.
%
% "newmatrix" is a normalized copy of "oldmatrix".


% Initialize.
newmatrix = oldmatrix;

% Make the reference one-dimensional to simplify function calls.
refvector = reshape(refmatrix, 1, []);


% Compute statistics on the reference matrix and normalize the input matrix.

if strcmp('median', method)

  % Use the median and inter-quartile range.

  newmatrix = newmatrix - median(refvector);

  quartiles = prctile(refvector, [ 25 75 ]);
  thisrad = 0.5 * (quartiles(2) - quartiles(1));

  % One quartile is 0.67 standard deviations for normal data.
  newmatrix = 0.67 * newmatrix / thisrad;

elseif strcmp('twosided', method)

  % Use the median and individual quartiles.

  medval = median(refvector);
  newmatrix = newmatrix - medval;

  % We want unsigned magnitude, not signed values.
  posrad = prctile(refvector, 75) - medval;
  negrad = medval - prctile(refvector, 25);

  posmask = (newmatrix >= 0);
  negmask = ~posmask;

  % One quartile is 0.67 standard deviations for normal data.
  newmatrix(posmask) = 0.67 * newmatrix(posmask) / posrad;
  newmatrix(negmask) = 0.67 * newmatrix(negmask) / negrad;

else
  % Default to standard z-score.
  newmatrix = newmatrix - mean(refvector);
  newmatrix = newmatrix / std(refvector);
end


% Done.
end

%
% This is the end of the file.
