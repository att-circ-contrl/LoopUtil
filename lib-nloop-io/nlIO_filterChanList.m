function newlist = nlIO_filterChanList( oldlist, filterrules )

% function newlist = nlIO_filterChanList( oldlist, filterrules )
%
% This function filters a channel list, keeping or discarding entries
% according to user-specified filter rules.
%
% "oldlist" is a channel list to filter, per "CHANLIST.txt".
% "filterrules" is a structure with zero or more of the following fields:
%   "keepfolders" is a cell array containing regex patterns that folder labels
%     must match.
%   "omitfolders" is a cell array containing regex patterns that folder labels
%     must not match.
%   "keepbanks" is a cell array containing regex patterns that bank labels
%     must match.
%   "omitbanks" is a cell array containing regex patterns that bank labels
%     must not match.
%   "keepchans" is a vector containing channel indices that should be kept.
%     Any channels not in this list are discarded.
%   "omitchans" is a vector containing channel indices that must be discarded.
%   "keepbanktypes" is a cell array containing bank type identifiers that
%     should be matched. Any bank type identifiers not in this list are
%     discarded.
%   "omitbanktypes" is a cell array containing bank type identifiers that
%     must not be matched.
%
% "newlist" is a subset of "oldlist" containing entries that pass all rules.


% Copy filter rules, setting defaults if rules are missing.

keepfolders = {};
omitfolders = {};
if isfield(filterrules, 'keepfolders')
  keepfolders = filterrules.keepfolders;
end
if isfield(filterrules, 'omitfolders')
  omitfolders = filterrules.omitfolders;
end

keepbanks = {};
omitbanks = {};
if isfield(filterrules, 'keepbanks')
  keepbanks = filterrules.keepbanks;
end
if isfield(filterrules, 'omitbanks')
  omitbanks = filterrules.omitbanks;
end

keepchans = [];
omitchans = [];
if isfield(filterrules, 'keepchans')
  keepchans = filterrules.keepchans;
end
if isfield(filterrules, 'omitchans')
  omitchans = filterrules.omitchans;
end

keeptypes = {};
omittypes = {};
if isfield(filterrules, 'keepbanktypes')
  keepbanktypes = filterrules.keepbanktypes;
end
if isfield(filterrules, 'omitbanktypes')
  omitbanktypes = filterrules.omitbanktypes;
end


% Do the filtering.

newlist = struct();
foldernames = fieldnames(oldlist);

for fidx = 1:length(foldernames)
  thisfoldername = foldernames{fidx};
  oldfolder = oldlist.(thisfoldername);

  % Filter on channel name.
  if helper_testLabel(thisfoldername, keepfolders, omitfolders)

    newfolder = struct();
    had_folder_data = false;
    banknames = fieldnames(oldfolder);

    for bidx = 1:length(banknames)
      thisbankname = banknames{bidx};
      oldbank = oldfolder.(thisbankname);

      thistype = '';
      if isfield(oldbank, 'scalarmeta')
        if isfield(oldbank.scalarmeta, 'banktype')
          thistype = oldbank.scalarmeta.banktype;
        end
      end

      % Filter on bank name and, if present, bank type.
      if helper_testLabel(thisbankname, keepbanks, omitbanks) ...
        && ( isempty(thistype) ...
          || helper_testLabel(thistype, keeptypes, omittypes) )

        newbank = struct();
        had_bank_data = false;

        chanmask = helper_testNumbers(oldbank.chanlist, keepchans, omitchans);
        if sum(chanmask) > 0
          had_folder_data = true;
          had_bank_data = true;

          oldchancount = length(oldbank.chanlist);
          oldfields = fieldnames(oldbank);

          for nidx = 1:length(oldfields)
            thisfieldname = oldfields{nidx};
            olddata = oldbank.(thisfieldname);

            % NOTE - Anything that's not "scalarmeta" is assumed to be
            % per-channel metadata. Anything the wrong length is silently
            % discarded!

            if strcmp('scalarmeta', thisfieldname)
              % Scalar metadata structure.
              newbank.(thisfieldname) = olddata;
            elseif length(olddata) == oldchancount
              % Per-channel metadata (or the channel list itself). Filter it.
              newbank.(thisfieldname) = olddata(chanmask);
            else
              % Count doesn't match!
              % FIXME - Silently discard this.
            end
          end
        end

        if had_bank_data
          newfolder.(thisbankname) = newbank;
        end

      end
    end

    if had_folder_data
      newlist.(thisfoldername) = newfolder;
    end

  end
end


% Done.

end



%
% Helper functions.


% This tests a label against a supplied whitelist and blacklist.
% NOTE - The whitelist and blacklist elements are regexes!
% An empty list always passes.
% The test label must otherwise be in the keep list and not in the omit list.

function result = helper_testLabel(thelabel, keeplabels, omitlabels)

  had_keep = false;
  had_omit = false;

  if isempty(keeplabels)
    had_keep = true;
  else
    for pidx = 1:length(keeplabels)
      thispattern = keeplabels{pidx};
      matchlist = regexp(thelabel, thispattern, 'match');
      if length(matchlist) > 0
        had_keep = true;
      end
    end
  end

  if isempty(omitlabels)
    had_omit = false;
  else
    for pidx = 1:length(omitlabels)
      thispattern = omitlabels{pidx};
      matchlist = regexp(thelabel, thispattern, 'match');
      if length(matchlist) > 0
        had_omit = true;
      end
    end
  end

  result = had_keep & (~had_omit);

end


% This tests a set of numbers against a supplied whitelist and blacklist.
% An empty list always passes.
% The result is a mask vector the same size as the test vector.

function resultmask = helper_testNumbers(testlist, keeplist, omitlist)

  keepmask = true(size(testlist));
  if ~isempty(keeplist)
    keepmask = ismember(testlist, keeplist);
  end

  omitmask = false(size(testlist));
  if ~isempty(omitlist)
    omitmask = ismember(testlist, omitlist);
  end

  resultmask = keepmask & (~omitmask);

end


%
% This is the end of the file.
