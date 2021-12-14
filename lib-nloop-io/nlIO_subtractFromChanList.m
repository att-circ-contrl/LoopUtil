function newlist = nlIO_subtractFromChanList(oldlist, removelist)

% function newlist = nlIO_subtractFromChanList(oldlist, removelist)
%
% This function removes the specified members from a channel list, if the
% members are present.
%
% "oldlist" is the channel list (per "CHANLIST.txt").
% "removelist" is a channel list containing members to be removed.
%
% "newlist" is a copy of "oldlist" that does not contain any members that
%   were listed in "removelist".


newlist = struct();
foldernames = fieldnames(oldlist);

for fidx = 1:length(foldernames)
  thisfoldername = foldernames{fidx};
  oldfolder = oldlist.(thisfoldername);

  if ~isfield(removelist, thisfoldername)
    newlist.(thisfoldername) = oldfolder;
  else

    removefolder = removelist.(thisfoldername);
    newfolder = struct();
    had_folder_data = false;

    banknames = fieldnames(oldfolder);
    for bidx = 1:length(banknames)
      thisbankname = banknames{bidx};
      oldbank = oldfolder.(thisbankname);

      if ~isfield(removefolder, thisbankname)
        newfolder.(thisbankname) = oldbank;
      else

        removebank = removefolder.(thisbankname);
        newbank = struct();
        had_bank_data = false;

        chanmask = ~ismember(oldbank.chanlist, removebank.chanlist);
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
% This is the end of the file.
