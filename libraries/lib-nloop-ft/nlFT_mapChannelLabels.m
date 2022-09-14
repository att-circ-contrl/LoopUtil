function newlabels = nlFT_mapChannelLabels( oldlabels, lutold, lutnew )

% function newlabels = nlFT_mapChannelLabels( oldlabels, lutold, lutnew )
%
% This function translates channel labels according to a lookup table.
% This is intended to be used for channel mapping.
%
% "oldlabels" is a cell array containing labels to translate.
% "lutold" is a cell array containing old labels that correspond to the
%   labels in "lutnew".
% "lutnew" is a cell array containing new labels that correspond to the
%   labels in "lutold".
%
% "newlabels" is a cell array of translated labels. Old labels are turned
%   into corresponding new labels. Labels that can't be translated are
%   replaced with ''.


newlabels = {};

for lidx = 1:length(oldlabels)

  % Do the translation.
  % We'll end up with zero, one, or multiple matches in a cell array.

  thisold = oldlabels{lidx};
  lutmask = strcmp(thisold, lutold);
  thisnew = lutnew(lutmask);

  % Get exactly one cell and save it.

  if isempty(thisnew)
    thisnew = { '' };
  else
    thisnew = thisnew(1);
  end

  % Make this a column vector, for consistency with hdr.label.
  newlabels = [ newlabels ; thisnew ];

end


% Done.

end


%
% This is the end of the file.
