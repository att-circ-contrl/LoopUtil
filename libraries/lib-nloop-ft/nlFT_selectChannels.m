function nlFT_selectChannels( typeswanted, nameswanted, bankswanted )

% function nlFT_selectChannels( typeswanted, nameswanted, bankswanted )
%
% This sets conditions that chanels must match in order to be processed.
% Channels must have a desired type, have a name that matches a desired
% regex, or be part of a bank whose label matches a desired regex.
%
% Individual channel and bank names are valid regex patterns.
%
% Empty lists always match (so pass "{}" as a condition to disable that test).
%
% "typeswanted" is a cell array containing a list of labels. The channel
%   type (from LoopUtil's "banktype" or Field Trip's "chantype") must be in
%   the list for the channel to be processed.
% "nameswanted" is a cell array containing a list of regex patterns. The
%   channel name (from Field Trip's "label") must match one of the regexes
%   in the list for the channel to be processed.
% "bankswanted" is a cell array containing a list of regex patterns. The
%   bank name (from LoopUtil; used as the prefix for channel names) must
%   match one of the regexes in the list for the channel to be processed.
%
% FIXME - This stores state as global variables. This was the least-ugly way
% of implementing channel and bank filtering without modifying Field Trip.


% Import global variables.

global nlFT_selectChannels_typeswanted;
global nlFT_selectChannels_nameswanted;
global nlFT_selectChannels_bankswanted;


% Set new values for the criteria lists.

nlFT_selectChannels_typeswanted = typeswanted;
nlFT_selectChannels_nameswanted = nameswanted;
nlFT_selectChannels_bankswanted = bankswanted;


% Done.

end


%
% This is the end of the file.
