function nlFT_setMemChans(newcount)

% function nlFT_setMemChans(newcount)
%
% This sets the maximum number of data channels that can be loaded into
% memory at one time (the "memchans" argument for NeuroLoop iterating
% functions).
%
% The higher this is, the faster data is read, due to not having to repeatedly
% scan over data files that store matrix data. The downside is that memory
% requirements can get big very quickly (typically 1 gigabyte per
% channel-hour of data).
%
% "newcount" is the new maximum number of memory-resident channels.
%
% FIXME - This stores state as global variables. This was the least-ugly
% way of passing tuning parameters to low-level reading functions.


% Import the global variable.

global nlFT_setMemChans_memchans;


% Store the new value.

newcount = round(newcount);
newcount = max(1,newcount);

nlFT_setMemChans_memchans = newcount;


% Done.

end


%
% This is the end of the file.
