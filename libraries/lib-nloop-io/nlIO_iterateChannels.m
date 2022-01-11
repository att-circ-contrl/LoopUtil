function resultvals = ...
  nlIO_iterateChannels(metadata, chanlist, memchans, procfunc)

% function resultvals = ....
%   nlIO_iterateChannels(metadata, chanlist, memchans, procfunc)
%
% This iterates through a set of channels, loading each channel's waveform
% data in sequence and calling a processing function with that data.
% Processing output is aggregated and returned.
%
% This is implemented such that only a few channels are loaded at a time.
%
% Channel time series are stored as sample numbers (not times). Analog data
% is converted to microvolts. TTL data is converted to boolean.
%
% "metadata" is a project metadata structure, per FOLDERMETA.txt.
% "chanlist" is a structure listing channels to process, per CHANLIST.txt.
% "memchans" is the maximum number of channels that may be loaded into
%   memory at the same time.
% "procfunc" is a function handle used to transform channel waveform data
%   into "result" data, per PROCFUNC.txt.
%
% "resultvals" is a channel list structure that has bank-level channel lists
%   augmented with a "resultlist" field, per CHANLIST.txt. The "resultlist"
%   field is a cell array containing per-channel output from "procfunc".


% Initialize output.
resultvals = struct();


% Iterate through the list, wrapping vendor-specific functions per folder.

folderlist = fieldnames(chanlist);
for fidx = 1:length(folderlist)

  % Make sure this folder actually exists before processing it.
  thisflabel = folderlist{fidx};

  if isfield(metadata.folders, thisflabel)
    thisfoldermeta = metadata.folders.(thisflabel);
    thisfolderchans = chanlist.(thisflabel);
    thisdevice = thisfoldermeta.devicetype;

    if strcmp(thisdevice, 'intan')
      resultvals.(thisflabel) = nlIntan_iterateFolderChannels( ...
        thisfoldermeta, thisfolderchans, memchans, procfunc, ...
        metadata, thisflabel );
    elseif strcmp(thisdevice, 'openephys')
      resultvals.(thisflabel) = nlOpenE_iterateFolderChannels( ...
        thisfoldermeta, thisfolderchans, memchans, procfunc, ...
        metadata, thisflabel );
    else
      % FIXME - Diagnostics.
      disp(sprintf( '###  Not sure how to iterate a "%s" folder.', ...
        thisdevice ));
    end
  end

end




% Done.

end


%
% This is the end of the file.
