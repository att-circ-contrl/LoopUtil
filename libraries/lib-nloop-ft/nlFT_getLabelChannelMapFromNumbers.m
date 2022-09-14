function [ maplabelsraw maplabelscooked ] = ...
  nlFT_getLabelChannelMapFromNumbers( ...
    chanmap, idxlabelsraw, idxlabelscooked )

% function [ maplabelsraw maplabelscooked ] = ...
%   nlFT_getLabelChannelMapFromNumbers( ...
%     chanmap, idxlabelsraw, idxlabelscooked )
%
% This function translates a channel mapping table defined using channel
% indices into a channel mapping table defined using labels.
%
% "chanmap" is a vector indexed by cooked channel number containing the raw
%   channel number that maps to each cooked location, or NaN if none does.
%   the first channel index is 1, per Matlab conventions.
% "idxlabelsraw" is a cell array containing all raw channel names.
% "idxlabelscooked" is a cell array containing all cooked channel names.
%
% "maplabelsraw" is a cell array containing raw channel names that correspond
%   to the names in "maplabelscooked".
% "maplabelscooked" is a cell array containing cooked channel names that
%   correspond to the names in "maplabelsraw".


% Bulletproof the channel map.

rawcount = length(idxlabelsraw);
cookedcount = length(idxlabelscooked);

% Entries must _correspond_ to valid cooked channels.
if length(chanmap) > cookedcount
  chanmap = chanmap(1:cookedcount);
end

% Entries must _point_ to valid raw channels.
validmask = (chanmap >= 1) & (chanmap <= rawcount);
goodmap = chanmap(validmask);


% Copy the raw and cooked labels.

maplabelscooked = idxlabelscooked(validmask);
maplabelsraw = idxlabelsraw(goodmap);


% Done.

end


%
% This is the end of the file.
