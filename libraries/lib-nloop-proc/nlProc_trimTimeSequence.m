function newlist = nlProc_trimTimeSequence( oldlist, timespan )

% function newlist = nlProc_trimTimeSequence( oldlist, timespan )
%
% This accepts a list of timestamps and removes any that are outside of the
% specified timespan.
%
% "oldlist" is a vector of timestamps to prune.
% "timespan" [ min max ] specifies the range of accepted timestamps.
%
% "newlist" is a vector of timestamps that were within the desired
% timestamp range.


firsttime = min(timespan);
lasttime = max(timespan);

tmask = (oldlist >= firsttime) & (oldlist <= lasttime);

newlist = oldlist(tmask);


% Done.
end


%
% This is the end of the file.
