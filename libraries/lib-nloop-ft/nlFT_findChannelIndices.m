function newindices = nlFT_findChannelIndices( ftheader, chanlabels )

% function newindices = nlFT_findChannelIndices( ftheader, chanlabels )
%
% This returns a vector of Field Trip channel indices corresponding to the
% specified list of Field Trip channel labels.
%
% NOTE - If channel labels aren't unique, a matching channel label is chosen
% arbitrarily. If channel labels aren't found in the FT header, an index of
% NaN is returned for that channel.


newindices = [];

ftlabels = ftheader.label;

for lidx = 1:length(chanlabels)
  thislabel = chanlabels{lidx};

  thisindex = min(find(strcmp(ftlabels, thislabel)));
  if isempty(thisindex)
    thisindex = NaN;
  end

  newindices(lidx) = thisindex;
end


% Done.

end


%
% This is the end of the file.
