function newdata = nlFT_zscoreTrials( olddata, refrange, method )

% function newdata = nlFT_zscoreTrials( olddata, refrange, method )
%
% This normalizes trials in a Field Trip dataset, z-scoring across time.
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
% "olddata" is a ft_datatype_raw structure with the trials to z-score.
% "refrange" [ min max ] is the timestamp range within trials to use for
%   computing z-scoring statistics.
% "method" is 'zscore', 'median', or 'twosided'.
%
% "newdata" is a normalized copy of "olddata".


% Copy the dataset.
newdata = olddata;


% Get metadata.

trialcount = length(newdata.time);
chancount = length(newdata.label);

mintime = min(refrange);
maxtime = max(refrange);


% Iterate trials and channels, performing normalization.

for tidx = 1:trialcount
  thistime = newdata.time{tidx};
  timemask = (thistime >= mintime) & (thistime <= maxtime);

  % This is Nchans x Nsamples.
  thistrial = newdata.trial{tidx};

  if any(timemask)
    for cidx = 1:chancount
      dataslice = thistrial(cidx,:);
      thistrial(cidx,:) = ...
        nlProc_normalizeSlice( dataslice, dataslice(timemask), method );
    end
  else
    % Not able to normalize. Squash the output.
    thistrial = nan(size(thistrial));
  end

  newdata.trial{tidx} = thistrial;
end


% Done.
end


%
% This is the end of the file.
