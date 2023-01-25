function wavedata = nlUtil_sparseToContinuousTime( ...
  eventtimes, eventvalues, firsttime, sampcount, samprate )

% function wavedata = nlUtil_sparseToContinuousTime( ...
%   eventtimes, eventvalues, firsttime, sampcount, samprate )
%
% This converts a sequence of nonuniformly-sampled events into a continuous
% waveform. Events are assumed to reflect the first instances of changed
% waveform values; this signal is held constant after each event until the
% next event is seen.
%
% This sorts the event list by timestamp prior to processing.
%
% Event timestamps are assumed to be times in seconds.
%
% "eventtimes" are the timestamps (in seconds) associated with each event.
% "eventvalues" are the data values associated with each event.
% "firsttime" is the timestamp of the first output sample to generate.
% "sampcount" is the number of output samples to generate.
% "samprate" is the sampling rate of the output waveform.
%
% "wavedata" is a waveform spanning the specified time range, where the
%   value of any given sample is the value of the most recently-seen event,
%   or zero if there were no prior events.


% Wrap the sample-based version.

eventindices = round( eventtimes * samprate );
firstindex = round( firsttime * samprate );
lastindex = firstindex + sampcount - 1;

wavedata = nlUtil_sparseToContinuous( eventindices, eventvalues, ...
  [ firstindex lastindex ] );


% Done.
end


%
% This is the end of the file.
