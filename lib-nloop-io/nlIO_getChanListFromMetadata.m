function chanlist = nlIO_getChanListFromMetadata(metadata)

% function chanlist = nlIO_getChanListFromMetadata(metadata)
%
% This generates a channel list describing all channels defined in the
% specified metadata structure. The "banktype" field is copied to the
% channel list scalar metadata structure to facilitate list filtering.
%
% "metadata" is a project metadata structure, per "FOLDERMETA.txt".
%
% "chanlist" is a channel list, per "CHANLIST.txt".

chanlist = struct();

folders = metadata.folders;
foldernames = fieldnames(folders);

for fidx = 1:length(foldernames)

  thisfname = foldernames{fidx};
  thisfolder = folders.(thisfname);

  banks = thisfolder.banks;
  banknames = fieldnames(banks);

  for bidx = 1:length(banknames)

    thisbname = banknames{bidx};
    thisbank = banks.(thisbname);

    bankchans = thisbank.channels;
    banktype = thisbank.banktype;

    if ~isempty(bankchans)
      % Remove duplicates and sort the channel list.
      bankchans = unique(bankchans);

      % Store this bank's channels and type specifier.
      if ~isfield(chanlist, thisfname)
        chanlist.(thisfname) = struct();
      end
      scalarmeta = struct( 'banktype', banktype );
      chanlist.(thisfname).(thisbname) = ...
        struct( 'chanlist', bankchans, 'scalarmeta', scalarmeta );
    end

  end

end


% Done.

end


%
% This is the end of the file.
