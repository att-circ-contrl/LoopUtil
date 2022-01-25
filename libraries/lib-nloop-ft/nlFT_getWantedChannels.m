function [ typeswanted nameswanted bankswanted ] = nlFT_getWantedChannels()


% function [ typeswanted nameswanted bankswanted ] = nlFT_getWantedChannels()
%
% This reports the type, name, and bank patterns set by the most recent
% call to nlFT_selectChannels().
%
% Types must match exactly. Individual channel and bank names are valid
% regex patterns. Empty lists of patterns or labels always match, indicating
% absence of filtering on that particular criterion.
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


% If anything hasn't been initialized, it has a value of "[]". Fi that.

if isempty(nlFT_selectChannels_typeswanted)
  nlFT_selectChannels_typeswanted = {};
end
if isempty(nlFT_selectChannels_nameswanted)
  nlFT_selectChannels_nameswanted = {};
end
if isempty(nlFT_selectChannels_bankswanted)
  nlFT_selectChannels_bankswanted = {};
end


% Report the current lists of criteria.

typeswanted = nlFT_selectChannels_typeswanted;
nameswanted = nlFT_selectChannels_nameswanted;
bankswanted = nlFT_selectChannels_bankswanted;


% Done.

end


%
% This is the end of the file.
