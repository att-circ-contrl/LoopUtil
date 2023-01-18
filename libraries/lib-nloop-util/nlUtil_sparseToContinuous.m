function wavedata = ...
  nlUtil_sparseToContinuous( eventtimes, eventvalues, samprange )

% function wavedata = ...
%   nlUtil_sparseToContinuous( eventtimes, eventvalues, samprange )
%
% This converts a sequence of nonuniformly-sampled events into a continuous
% waveform. Samples are assumed to reflect the first instances of changed
% waveform values; this signal is held constant at the last seen sample value.
%
% Events are sorted prior to processing.
%
% "eventtimes" are the timestamps (sample indices) associated with each event.
% "eventvalues" are the data values associated with each event.
% "samprange" [min max] is the span of sample indices to generate data for.
%
% "wavedata" is a waveform spanning the specified range of sample indices,
%   where the value of any given sample is the value of the most recently-seen
%   event, or zero if there were no prior events.


% Initialize.

firstsamp = min(samprange);
lastsamp = max(samprange);
sampcount = 1 + lastsamp - firstsamp;

datafunc = str2func(class(eventvalues));
wavedata = datafunc([]);


% Proceed if we have data.

if sampcount > 0

  % Sort the events.
  [ eventtimes, sortidx ] = sort(eventtimes);
  eventvalues = eventvalues(sortidx);

  % Get the starting value.
  startval = datafunc(0);
  if ~isempty(eventtimes)
    selectmask = (eventtimes <= firstsamp);
    if any(selectmask)
      selectidx = max(find(selectmask));
      startval = eventvalues(selectidx);
    end
  end

  % Initialize.
  wavedata(1:sampcount) = startval;

  % Get the samples that overlap the range of interest.
  selectmask = (eventtimes >= firstsamp) & (eventtimes <= lastsamp);
  eventtimes = eventtimes(selectmask);
  eventvalues = eventvalues(selectmask);

  % Augment the time list with the ending fencepost.
  % Data list doesn't need to be augmented.
  eventcount = length(eventtimes);
  eventtimes(eventcount + 1) = lastsamp + 1;

  % Shift times to match the output window.
  eventtimes = eventtimes + 1 - firstsamp;

  % Walk through the event list, rendering spans.
  for eidx = 1:eventcount
    thisstart = eventtimes(eidx);
    nextstart = eventtimes(eidx + 1);
    thisvalue = eventvalues(eidx);

    if nextstart > thisstart
      wavedata(thisstart:(nextstart-1)) = thisvalue;
    end
  end

end


% Done.

end


%
% This is the end of the file.
