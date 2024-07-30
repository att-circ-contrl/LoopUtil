function newmatrix = nlProc_normalizeAcrossChannels( oldmatrix, method )

% function newmatrix = nlProc_normalizeAcrossChannels( oldmatrix, method )
%
% This normalizes a 2- or 3-dimensional matrix with "channel" as the first
% dimension, z-scoring across channels.
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


% Names of the second and third dimension are arbitrary.
% For 2D matrices, "trialcount" reads as 1 and indexing is valid, so always
% treat these as 3D matrices.

chancount = size(oldmatrix,1);
bandcount = size(oldmatrix,2);
trialcount = size(oldmatrix,3);


for bidx = 1:bandcount
  for tidx = 1:trialcount

    thisslice = oldmatrix(:,bidx,tidx);

    if strcmp('median', method)

      % Use the median and inter-quartile range.

      thisslice = thisslice - median(thisslice);

      quartiles = prctile(thisslice, [ 25 75 ]);
      thisrad = 0.5 * (quartiles(2) - quartiles(1));

      % One quartile is 0.67 standard deviations for normal data.
      thisslice = 0.67 * thisslice / thisrad;

    elseif strcmp('twosided', method)

      % Use the median and individual quartiles.

      thisslice = thisslice - median(thisslice);

      % We've already subtracted the median.
      % We want unsigned magnitude, not signed values.
      posrad = prctile(thisslice, 75);
      negrad = abs( prctile(thisslice, 25) );

      posmask = (thisslice >= 0);
      negmask = ~posmask;

      % One quartile is 0.67 standard deviations for normal data.
      thisslice(posmask) = 0.67 * thisslice(posmask) / posrad;
      thisslice(negmask) = 0.67 * thisslice(negmask) / negrad;

    else
      % Default to standard z-score.
      thisslice = thisslice - mean(thisslice);
      thisslice = thisslice / std(thisslice);
    end

    newmatrix(:,bidx,tidx) = thisslice;

  end
end



% Done.
end

%
% This is the end of the file.
