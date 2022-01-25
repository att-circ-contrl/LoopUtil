function [ eventvals, eventtimes ] = ...
  nlUtil_continuousToSparse( wavedata, timedata )

% function [ eventvals, eventtimes ] = ...
%   nlUtil_continuousToSparse( wavedata, timedata )
%
% This converts a continuous discrete-valued waveform into a series of
% nonuniformly-sampled events (representing changes in the waveform's value).
%
% The waveform value is assumed to be discrete and changes are assumed to be
% infrequent. This will still work if given floating-point data or data that
% changes at every sample, but there's little point in representing these
% signals as event lists ("eventvals" and "eventtimes" will be copies of
% "wavedata" and "timedata", respectively).
%
% NOTE - There will always be an event at the first timestamp representing
% the initial data value.
%
% "wavedata" is a vector with samples from the continuous signal.
% "timedata" is a vector of timestamps corresponding to these samples.
%
% "eventvals" is a vector containing signal values immediately after changes.
% "eventtimes" is a vector containing the timestamps of these changes.


% Initialize.

datafunc = str2func(class(wavedata));
timefunc = str2func(class(timedata));

eventvals = datafunc([]);
eventtimes = timefunc([]);

datalength = length(wavedata);


% Record the initial value.

if datalength > 0
  eventvals(1) = wavedata(1);
  eventtimes(1) = timedata(1);
end


% Record subsequent changes.

if datalength > 1
  changemask = wavedata(1:(datalength-1)) ~= wavedata(2:datalength);
  changeindices = 1 + find(changemask);

  numchanges = length(changeindices);
  if numchanges > 0
    eventvals(2:(1+numchanges)) = wavedata(changeindices);
    eventtimes(2:(1+numchanges)) = timedata(changeindices);
  end
end


% Done.

end


%
% This is the end of the file.
