function memchans = nlFT_getMemChans()

% function memchans = nlFT_getMemChans()
%
% This queries the maximum number of data channels that can be loaded into
% memory at one time (the "memchans" argument for NeuroLoop iterating
% functions).
%
% The higher this is, the faster data is read, due to not having to repeatedly
% scan over data files that store matrix data. The downside is that memory
% requirements can get big very quickly (typically 1 gigabyte per
% channel-hour of data).
%
% "memchans" is the current maximum number of memory-resident channels.
%
% FIXME - This stores state as global variables. This was the least-ugly
% way of passing tuning parameters to low-level reading functions.


% Import the global variable.

global nlFT_setMemChans_memchans;


% If this hasn't been initialized, it has a value of "[]". Fix that.
if isempty(nlFT_setMemChans_memchans)
  nlFT_setMemChans_memchans = 1;
end


% Return the value.

memchans = nlFT_setMemChans_memchans;


% Done.

end


%
% This is the end of the file.
