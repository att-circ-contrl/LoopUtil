function eventlist = nlFT_readEventsContinuous( indir, header )

% function eventlist = nlFT_readEventsContinuous( indir, header )
%
% This probes the specified directory using nlIO_readFolderMetadata(), and
% looks for an appropriate channel to read as a sparse event list.
%
% This is intended to be called by ft_read_event() via the "eventformat"
% argument.
%
% NOTE - Field Trip expects this to return the header, rather than an event
% list, if it's called with just one argument ("indir").
%
% The "nlFT_selectChannels()" function should have been called to ensure
% that exactly one event channel is detected. Results from selecting multiple
% channels are undefined (in practice it'll pick one channel arbitrarily).
%
% "indir" is the directory to process.
% "header" is the Field Trip header associated with this directory.
%
% "eventlist" is a vector of field trip event records with the "sample",
%   "value", and "type" fields filled in. The "type" field contains the
%   channel signal type (such as "eventbool" or "eventwords").


% FIXME - Special-case Field Trip's "I just want the header" call.
if nargin < 2
  eventlist = nlFT_readHeader(indir);
  return;
end


% Initialize output.
eventlist = struct( 'sample', {}, 'value', {}, 'type', {} );

% Call the "read everything" function.
% If the user specified a continuous channel, turn it into sparse data.
wantpromote = true;
allevents = nlFT_readAllEvents(indir, wantpromote);

% If we have at least one event array in the list, return the first one.
if isempty(allevents)
  % FIXME - Diagnostics.
  disp('###  Called nlFT_readEvents() with no channels selected.');
else
  if length(allevents) > 1
    % FIXME - Diagnostics.
    disp('###  Called nlFT_readEvents() with multiple channels selected.');
  end

  eventlist = allevents(1).ftevents;
end


% Done.

end


%
% This is the end of the file.
