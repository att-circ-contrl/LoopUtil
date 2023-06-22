function [ newlist passvec ] = ...
  nlUtil_pruneStructureList( oldlist, filterlists )

% function [ newlist passvec ] = ...
%   nlUtil_pruneStructureList( oldlist, filterlists )
%
% This accepts a structure array or a cell array of structures and builds a
% new list containing only those records that pass user-specified whitelist
% and blacklist filters on structure field contents.
%
% If a whitelist and a blacklist are both present for a given field, the
% whitelist is applied first, followed by the blacklist.
%
% If a field is absent, blacklist tests on it pass but whitelist tests fail.
%
% Tested field values may be scalars or character vectors.
%
% Tests can be performed on the concatenation of multiple character vector
% fields. Testing on concatenated scalar values is not supported.
%
% "oldlist" is a structure array or a cell array containing structures.
% "filterlists" is a structure array with the following fields:
%   "srcfield" is a character vector or a cell array. If it's a character
%     vector, it contains the name of the structure field to filter on. If
%     it's a cell array, it is assumed to contain one or more field names,
%     and the contents of those fields are concatenated.
%   "whitelist" is a vector or cell array containing field values to accept,
%     or [] or {} to accept all values.
%   "blacklist" is a vector or cell array containing field values to reject,
%     or [] or {} to pass all values.
%
% "newlist" is a copy of "oldlist" containing only those records that passed
%   all filters.
% "passvec" is a logical vector such that newlist = oldlist(passvec).


passvec = logical([]);

for ridx = 1:length(oldlist)

  if iscell(oldlist)
    thisrec = oldlist{ridx};
  else
    thisrec = oldlist(ridx);
  end

  passed_whitelist = true;
  passed_blacklist = true;

  for fidx = 1:length(filterlists)

    thisfilt = filterlists(fidx);


    % Get the data to filter on.
    % This could be from one source field or from many (concatenated).

    srcnames = thisfilt.srcfield;
    if ~iscell(srcnames)
      srcnames = { srcnames };
    end

    had_data = true;
    srcval = '';

    for nidx = 1:length(srcnames)
      thisname = srcnames{nidx};

      if ~isfield(thisrec, thisname)
        had_data = false;
      else
        % Data might be numeric or might be a character vector. Handle both.
        if isempty(srcval)
          srcval = thisrec.(thisname);
        else
          srcval = [ srcval thisrec.(thisname) ];
        end
      end
    end


    % Do the filtering.

    if ~had_data

      % If we're whitelisting on a field that's missing, the test fails.
      if ~isempty(thisfilt.whitelist)
        passed_whitelist = false;
      end

    else

      % FIXME - Filtering on individual numeric values works, and on
      % concatenated character vectors works, but not concatenated numeric
      % data!

      if ~isempty(thisfilt.whitelist)
        if ~ismember(srcval, thisfilt.whitelist)
          passed_whitelist = false;
        end
      end

      if ~isempty(thisfilt.blacklist)
        if ismember(srcval, thisfilt.blacklist)
          passed_blacklist = false;
        end
      end

    end
  end

  passvec(ridx) = passed_whitelist & passed_blacklist;

end


newlist = oldlist(passvec);


% Done.
end


%
% This is the end of the file.
