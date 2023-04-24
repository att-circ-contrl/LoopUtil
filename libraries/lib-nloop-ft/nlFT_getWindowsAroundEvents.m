function masklist = nlFT_getWindowsAroundEvents( ftdataset, window_ms )

% function masklist = nlFT_getWindowsAroundEvents( ftdataset, window_ms )
%
% This function builds per-trial mask vectors selecting windows around
% trial triggering events (i.e. around the t=0 point in trials).
%
% "ftdataset" is a structure of type ft_datatype_raw holding the trial data.
% "window_ms" [ start stop ] is a vector containing the time range to accept
%   (around each trial's t=0 point). This is in milliseconds.
%
% "masklist" is a 1xNtrials cell array with one cell per trial. Each cell
%   contains a 1xNsamples logical vector that's true in the accept window
%   and false elsewhere.


masklist = {};


% We're around t=0 and already have a time sequence for each trial.

trialcount = length(ftdataset.time);
firsttime = min(window_ms) * 0.001;
lasttime = max(window_ms) * 0.001;

for tidx = 1:trialcount
  thistime = ftdataset.time{tidx};

  % The time series is a 1xNsamples vector, so geometry is already correct.
  thismask = (thistime >= firsttime) & (thistime <= lasttime);
  masklist{tidx} = thismask;
end


% Done.
end


%
% This is the end of the file.
