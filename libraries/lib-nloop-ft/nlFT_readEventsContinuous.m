function eventlist = nlFT_readEventsContinuous( indir, header )

% function eventlist = nlFT_readEventsContinuous( indir, header )
%
% This probes the specified directory using nlIO_readFolderMetadata(), and
% reads events from all sparse (event-type) or discrete-valued continuous
% (boolean/integer/flagvector) channels found. The channel name for each
% event is stored in the event's "type" field.
%
% This is intended to be called by ft_read_event() via the "eventformat"
% argument.
%
% NOTE - Field Trip expects this to return the header, rather than an event
% list, if it's called with just one argument ("indir").
%
% NOTE - Timestamps are guaranteed to be in order, but there are no order
% guarantees for events with the same timestamp (such as simultaneous events
% from different channels).
%
% "indir" is the directory to process.
% "header" is the Field Trip header associated with this directory.
%
% "eventlist" is a vector of field trip event records with the "sample",
%   "value", and "type" fields filled in. The "type" field contains the
%   label of the channel that sourced the event.


% FIXME - Special-case Field Trip's "I just want the header" call.
if nargin < 2
  eventlist = nlFT_readHeader(indir);
  return;
end


% Call the "read everything" function.

% We want to promote discrete-valued continuous data into sparse event data.
wantpromote = true;
allevents = nlFT_readAllEvents(indir, wantpromote);


% Merge everything that we found into one event list.
% This tolerates finding nothing.

eventlist = nlFT_mergeEvents(allevents);


% Done.

end


%
% This is the end of the file.
