function thismap = ...
  nlOpenE_parseChannelMapGeneric_v5( chanlist, reflist, reflut, enlist )

% function thismap = ...
%   nlOpenE_parseChannelMapGeneric_v5( chanlist, reflist, reflut, enlist )
%
% This parses an array of source channel indices indices, an array of
% reference set indices, a reference lookup list, and an array of "enabled"
% flags, and assembles a structure describing this channel mapping (per
% "OPENEPHYS_CHANMAP.txt").
%
% NOTE - Reference banks start at 1, not 0. Convert before calling.
%
% This is intended to be called by other nlOpenE_parseChannelMap functions.
%
% "chanlist" is a vector indexed by new channel number containing the old
%   channel number that maps to each new location, or NaN if none does.
% "reflist" is a vector indexed by new channel number containing the
%   reference bank number to be used with each new channel. This may be [].
% "reflut" is a vector indexed by reference bank number listing the old
%   channel number to be used as a reference for each reference bank.
%   This may be [].
% "enlist" is a vector of boolean values indexed by new channel number
%   indicating which new channels are enabled. This may be [].
%
% "thismap" is a structure with the following fields:
%   "oldchan" is a vector indexed by new channel number containing the old
%     channel number that maps to each new location, or NaN if none does.
%   "oldref" is a vector indexed by new channel number containing the old
%     channel number to be used as a reference for each new location, or
%     NaN if unspecified.
%   "isenabled" is a vector of boolean values indexed by new channel number
%     indicating which new channels are enabled.


% Initialize.
thismap = struct([]);


% Initialize the enabled flag vector to defaults if we don't have one.
if isempty(enlist)
  enlist = true(size(chanlist));
end
% Make sure the enabled list is boolean.
enlist = (enlist > 0.5);


% Process references if we have enough information. Otherwise set to NaN.
if isempty(reflist) || isempty(reflut)
  reflist = NaN(size(chanlist));
else
  reflist = helper_translateRefs(reflist, reflut);
end


% Force consistency and make everything column vectors.

if ~iscolumn(chanlist)
  chanlist = chanlist';
end
if ~iscolumn(reflist)
  reflist = reflist';
end
if ~iscolumn(enlist)
  enlist = enlist';
end


% Save the resulting channel map information.
thismap = ...
  struct( 'oldchan', chanlist, 'oldref', reflist, 'isenabled', enlist );


% Done.

end


%
% Helper Functions

function newrefs = helper_translateRefs(oldrefs, reflut)

  % NOTE - We're already using 1-based reference indices.

  % Squash "no reference" entries in the LUT. These are "-1".
  % This tolerates an empty reference LUT.
  reflut(reflut < 0) = NaN;

  % Mask invalid entries in "oldrefs", too.
  refcount = length(reflut);
  oldmask = (oldrefs >= 1) & (oldrefs <= refcount);
  oldrefs(~oldmask) = NaN;

  % Translate the valid entries.
  % These are guaranteed to be in the LUT.
  oldrefs(oldmask) = reflut( oldrefs(oldmask) );

  % Done.
  newrefs = oldrefs;

end


%
% This is the end of the file.
