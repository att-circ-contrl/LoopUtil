function indexlist = nlUtil_getLabelIndices( labellist, labellut )

% function indexlist = nlUtil_getLabelIndices( labellist, labellut )
%
% This function translates a list of labels into a list of indices,
% corresponding to the locations of the labels in a master lookup table.
% Entries that aren't found have indices of NaN.
%
% "labellist" is a cell array of character vectors holding labels.
% "labellut" is a cell array of character vectors holding lookup table
%   labels. These entries should be unique (the first matching entry is
%   used in lookups).
%
% "indexlist" is a vector of the same size as "labellist" holding indices
%   into the lookup table, such that labellist(k) = labellut(indexlist(k)).


indexlist = NaN(size(labellist));

for lidx = 1:length(labellist)
  thislabel = labellist{lidx};

  % This returns [] if not found.
  thisindex = min(find(strcmp( thislabel, labellut )));

  if ~isempty(thisindex)
    indexlist(lidx) = thisindex;
  end
end


% Done.
end


%
% This is the end of the file.
