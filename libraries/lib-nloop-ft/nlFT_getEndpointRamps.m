function ramptrials = nlFT_getEndpointRamps( ftdata, spanfrac )

% function ramptrials = nlFT_getEndpointRamps( ftdata, spanfrac )
%
% This segments signals into NaN and non-NaN regions, and constructs
% piecewise-linear background connecting the endpoints of all non-NaN
% regions (defined across the entire data series, including NaN regions).
%
% This is intended to be subtracted before filtering to suppress ringing
% from discontinuities in the signal and its derivative.
%
% This is a wrapper for nlArt_getEndpointRamps.
%
% "ftdata" is a ft_datatype_raw dataset to process.
% "spanfrac" is the fraction of the length of non-NaN spans to keep at each
%   endpoint when estimating the line fit (e.g. 0.05 to pay attention to the
%   first and last 5% of each non-NaN segment). This is intended to suppress
%   transient samples at the endpoints. If this is 0 or NaN, only the first
%   and last sample of each non-NaN region are used.
%
% "ramptrials" is a copy of ftdata.trial with data replaced by piecewise
%   linear background fits.


ramptrials = ftdata.trial;

trialcount = length(ftdata.time);
chancount = length(ftdata.label);

for tidx = 1:trialcount
  thistrial = ramptrials{tidx};

  for cidx = 1:chancount
    thiswave = thistrial(cidx,:);
    thiswave = nlArt_getEndpointRamps(thiswave, spanfrac);
    thistrial(cidx,:) = thiswave;
  end

  ramptrials{tidx} = thistrial;
end


% Done.
end


%
% This is the end of the file.
