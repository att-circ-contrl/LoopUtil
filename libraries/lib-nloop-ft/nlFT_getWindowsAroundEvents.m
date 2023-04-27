function masklist = ...
  nlFT_getWindowsAroundEvents( ftdataset, window_ms, evtimes_sec )

% function masklist = ...
%   nlFT_getWindowsAroundEvents( ftdataset, window_ms, evtimes_sec )
%
% This function builds per-trial mask vectors selecting windows around
% trial triggering events (the t=0 point in trials), or against a
% user-specified list of event times.
%
% This handles overlapping trials and multiple events falling within a trial
% correctly.
%
% "ftdataset" is a structure of type ft_datatype_raw holding the trial data.
% "window_ms" [ start stop ] is a vector containing the time range to accept
%   around each event. This is in milliseconds.
% "evtimes_sec" is a vector containing event timestamps in seconds. If this
%   is [], the t=0 points in each trial are used instead.
%
% "masklist" is a 1xNtrials cell array with one cell per trial. Each cell
%   contains a 1xNsamples logical vector that's true in the accept window
%   and false elsewhere.


masklist = {};


% Convert the window to seconds.

winbefore = min(window_ms) * 0.001;
winafter = max(window_ms) * 0.001;


% Get other metadata.

trialcount = length(ftdataset.time);
samprate = ftdataset.hdr.Fs;
ftconfig = ftdataset.cfg;



%
% Get a list of absolute time series and absolute trigger times.

trialtimes = ftdataset.time;
trialtrigs = [];


% Find the trial start times.

firsttimes = [];

if isfield(ftdataset, 'sampleinfo')

  % This has the first and last absolute sample index of each trial.
  firsttimes = ftdataset.sampleinfo(:,1);

% FIXME - Diagnostics.
%disp('xx Getting trial times from sampleinfo.');

  % FIXME - Assume sample indices are 1-based.
  firsttimes = firsttimes - 1;
  firsttimes = firsttimes / samprate;

elseif isfield(ftconfig, 'trl')

  % This has trial start, trial end, and trigger offset (Ntrials x 3).
  % Trigger offset is positive if the trial starts after the trigger.
  firsttimes = ftconfig.trl(:,1);

% FIXME - Diagnostics.
%disp('xx Getting trial times from config.trl.');

  % FIXME - Assume sample indices are 1-based.
  firsttimes = firsttimes - 1;
  firsttimes = firsttimes / samprate;

elseif trialcount > 1

  % Multiple trials but no trial definitions.
  error('[nlFT_getWindowsAroundEvents]  Can''t find trial defintions.');

else

  % Only one trial (continuous data).
  % The time series doesn't need to be adjusted, and nominal trigger time
  % is t=0.

  firsttimes = 0;

end


% Use the trial start times to compute absolute time series and trigger times.

for tidx = 1:trialcount
  thistime = trialtimes{tidx};
  thisfirst = firsttimes(tidx);
  thisoffset = thisfirst - thistime(1);
  thistime = thistime + thisoffset;

  trialtimes{tidx} = thistime;
  trialtrigs(tidx) = thisoffset;
end


% If we don't have an event list, use the trigger times.
if isempty(evtimes_sec)
  evtimes_sec = trialtrigs;
end



% Walk through the trials, and identify windows that overlap each trial.

for tidx = 1:trialcount
  thistime = trialtimes{tidx};

  % Remember that the window start doesn't need to be negated.
  minevtime = min(thistime) + winafter;
  maxevtime = max(thistime) + winbefore;

  evmask = (evtimes_sec >= minevtime) & (evtimes_sec <= maxevtime);
  evsubset = evtimes_sec(evmask);

  % The time series is a 1xNsamples vector, so geometry is already correct.
  thismask = false(size(thistime));

  for eidx = 1:length(evsubset)
    thisev = evsubset(eidx);

    % Remember that the window start doesn't need to be negated.
    thisevfirst = thisev + winbefore;
    thisevlast = thisev + winafter;

    thismask = thismask | ...
      ( (thistime >= thisevfirst) & (thistime <= thisevlast) );
  end

  masklist{tidx} = thismask;
end


% Done.
end


%
% This is the end of the file.
