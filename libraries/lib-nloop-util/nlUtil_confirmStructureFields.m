function [ newlist passvec ] = ...
  nlUtil_confirmStructureFields( oldlist, fieldswanted )

% function [ newlist passvec ] = ...
%   nlUtil_confirmStructureFields( oldlist, fieldswanted )
%
% This accepts a structure array or a cell array of structures and builds a
% new list containing only those records that include the specified fields.
%
% "oldlist" is a structure array or a cell array containing structures.
% "fieldswanted" is a cell array containing the names of fields that must be
%   present.
%
% "newlist" is a copy of "oldlist" containing only those records that have
%   the desired fields.
% "passvec" is a logical vector such that newlist = oldlist(passvec).


passvec = logical([]);

for ridx = 1:length(oldlist)

  if iscell(oldlist)
    thisrec = oldlist{ridx};
  else
    thisrec = oldlist(ridx);
  end

  had_fields = true;

  for fidx = 1:length(fieldswanted)
    thisfield = fieldswanted{fidx};

    if ~isfield(thisrec, thisfield)
      had_fields = false;
    end
  end

  passvec(ridx) = had_fields;

end


newlist = oldlist(passvec);


% Done.
end


%
% This is the end of the file.
