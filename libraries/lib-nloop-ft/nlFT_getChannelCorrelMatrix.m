function [ rmatrix pmatrix ] = ...
  nlFT_getChannelCorrelMatrix( data_before, data_after )

% function [ rmatrix pmatrix ] = ...
%   nlFT_getChannelCorrelMatrix( data_before, data_after )
%
% This checks for correlation between channels in the "before" and "after"
% datasets, returning the correlation coefficients and null hypothesis
% P-values for each (before,after) pair (per the "corrcoef" function).
%
% The datasets must have the same sampling rate, the same number of trials,
% and the same number of samples in corresponding trials. Trials are
% concatenated to compute correlation statistics.
%
% NOTE - This is slow! Time goes up as the square of the number of channels.
% A progress banner is printed.
%
% NOTE - Matrix values are NaN for cases where an input had zero variance.
%
% "data_before" is a Field Trip dataset prior to channel mapping.
% "data_after" is a Field Trip dataset after channel mapping.
%
% "rmatrix" is a matrix indexed by (chanbefore,chanafter) containing
%   correlation coefficient values.
% "pmatrix" is a matrix indexed by (chanbefore,chanafter) containing P-values
%   for the null hypothesis (that the channels are not correlated).


beforecount = length(data_before.label);
aftercount = length(data_after.label);
trialcount = length(data_before.trial);

rmatrix = [];
pmatrix = [];

% Iterate channels as the outer loop and trials as the inner loop.
% This avoids having to concatenate the entire dataset at one time.

for srcidx = 1:beforecount
  % FIXME - Progress indicator.
  disp(sprintf( '.. Finding correlations for channel %d of %d...', ...
    srcidx, beforecount ));

  for dstidx = 1:aftercount

    beforeseries = [];
    afterseries = [];

    for tidx = 1:trialcount
      thisbefore = data_before.trial{tidx}(srcidx,:);
      thisafter = data_after.trial{tidx}(dstidx,:);
      beforeseries = horzcat(beforeseries, thisbefore);
      afterseries = horzcat(afterseries, thisafter);
    end

    % NOTE - We can get NaN if either input is perfectly flat (zero variance).
    [ thisrval, thispval ] = corrcoef( beforeseries, afterseries );
    rmatrix(srcidx,dstidx) = thisrval(1,2);
    pmatrix(srcidx,dstidx) = thispval(1,2);

  end
end

% FIXME - Progress indicator.
disp('.. Finished computing correlations.');


% Done.

end


%
% This is the end of the file.
