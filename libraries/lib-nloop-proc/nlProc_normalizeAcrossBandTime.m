function newmatrix = nlProc_normalizeAcrossBandTime( oldmatrix, method )

% function newmatrix = nlProc_normalizeAcrossBandTime( oldmatrix, method )
%
% This normalizes a 2- or 3-dimensional matrix with "band" or "time" as the
% second dimension, z-scoring across that dimension.
%
% This is intended to be used with nlProc_getBandPower() (which produces
% nChans x nBands x nTrials output), or with Field Trip's trial data (which
% is nChans x nSamples).
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
% "oldmatrix" is a nChans x nSamples or nChans x nBands x nTrials matrix.
% "method" is 'zscore', 'median', or 'twosided'.
%
% "newmatrix" is a normalized copy of "oldmatrix".


% Initialize.
newmatrix = nan(size(oldmatrix));


% Get metadata.
% Names of the second and third dimension are arbitrary.
% For 2D matrices, "trialcount" reads as 1 and indexing is valid, so always
% treat these as 3D matrices.

chancount = size(oldmatrix,1);
bandcount = size(oldmatrix,2);
trialcount = size(oldmatrix,3);


% Normalize slices.

for cidx = 1:chancount
  for tidx = 1:trialcount

    thisslice = oldmatrix(cidx,:,tidx);

    % Use the entire old slice as the reference region.
    newmatrix(cidx,:,tidx) = ...
      nlProc_normalizeSlice( thisslice, thisslice, method );

  end
end



% Done.
end

%
% This is the end of the file.
