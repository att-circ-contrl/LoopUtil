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


% Permute the input and call normalizeAcrossChannels().

oldmatrix = pagetranspose(oldmatrix);

newmatrix = nlProc_normalizeAcrossChannels( oldmatrix, method );

newmatrix = pagetranspose(newmatrix);


% Done.
end

%
% This is the end of the file.
