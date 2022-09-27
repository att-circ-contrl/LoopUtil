function [ srclabels, dstlabels ] = nlFT_getEstimatedChannelMapping( ...
  data_before, data_after, rmatrix, pmatrix )

% function [ srclabels, dstlabels ] = nlFT_getEstimatedChannelMapping( ...
%   data_before, data_after, rmatrix, pmatrix )
%
% This attempts to infer a channel mapping from "data_before" to "data_after"
% by looking at correlations between individual channels in each data set.
%
% The datasets must have the same sampling rate, the same number of trials,
% and the same number of samples in corresponding trials.
%
% Not all channels are guaranteed to be mapped. Channels that couldn't be
% mapped are omitted from the output. Order of labels in the output is not
% guaranteed.
%
% NOTE - Computing correlation values is slow! Time goes up as the square of
% the number of channels.
%
% "data_before" is a Field Trip dataset prior to channel mapping.
% "data_after" is a Field Trip dataset after channel mapping.
% "rmatrix" is the matrix of R-values returned by nlFT_getChannelCorrelMatrix.
%   If this argument is omitted, the R-value matrix is recomputed.
% "pmatrix" is the matrix of P-values returned by nlFT_getChannelCorrelMatrix.
%   If this argument is omitted, the P-value matrix is recomputed.
%
% "srclabels" is a cell array containing channel labels from "data_before".
% "dstlabels" is a cell array containing corresponding channel labels from
%   "data_after".


if ~( exist('rmatrix', 'var') && exist('pmatrix', 'var') )
  % NOTE - This is slow!
  [ rmatrix pmatrix ] = ...
    nlFT_getChannelCorrelMatrix( data_before, data_after );
end


% Use black magic to guess which source channels map to which destinations.

chansbefore = data_before.label;
chansafter = data_after.label;

srclabels = {};
dstlabels = {};

for srcidx = 1:length(chansbefore)
  dstidx = helper_guessDestination( rmatrix(srcidx,:), pmatrix(srcidx,:) );

  if ~isnan(dstidx)
    srclabels = horzcat( srclabels, chansbefore(srcidx) );
    dstlabels = horzcat( dstlabels, chansafter(dstidx) );
  end
end


% Prune duplicates. This only happens when matches are poor.
% NOTE - We aren't saving a FOM, so we can't tell which matches to keep!

if length(unique(dstlabels)) < length(dstlabels)
  % FIXME - Diagnostics.
  disp('.. Pruning duplicate matches.');

  isdup = [];

  for dstidx = 1:length(dstlabels)
    thislabel = dstlabels{dstidx};
    thisvec = strcmp(dstlabels, thislabel);
    isdup(dstidx) = (sum(thisvec) > 1);
  end

  keepvec = ~isdup;
  srclabels = srclabels(keepvec);
  dstlabels = dstlabels(keepvec);
end


% Done.

end


%
% Helper Functions


function dstidx = helper_guessDestination( dstrvals, dstpvals )

  % Perfectly correlated channels have an R-value of 1.0 and P-value of 0.
  % We're getting a whole lot of spurious P-values of 0, so use R-values.

  % Default to "not found".
  dstidx = NaN;


  % Get various statistics.
  % All of these functions tolerate NaNs but remove them anyways.

  cleanpvals = dstpvals(~isnan(dstpvals));
  pmin = min(cleanpvals);
  pmax = max(cleanpvals);
  plow = prctile(cleanpvals, 5);
  pthresh = min( 0.15 * pmin, 0.05 );

  cleanrvals = dstrvals(~isnan(dstrvals));
  rmax = max(cleanrvals);
  rmin = min(cleanrvals);
  rhigh = prctile(cleanrvals, 98);
%  rthresh = rmax;
  rthresh = 0.9999;


  % Do the detection.

  matchflags = (dstrvals >= rthresh);


  % If we have a single match, great. Multiple matches, not great.

  matchcount = sum(matchflags);

  if 1 == matchcount
    dstidx = find(matchflags);
  else
    % FIXME - Diagnostics.
%    disp(sprintf( '.. Ambiguous match (%d candidates found).', matchcount ));
%    disp(sprintf( 'min:  %.6f    max: %.6f    thresh:  %.6f', ...
%      pmin, pmax, pthresh ));
%    disp(dstpvals);
  end
end


%
% This is the end of the file.
