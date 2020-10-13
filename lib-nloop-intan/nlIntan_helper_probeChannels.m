function [ chandetect chanfiles ] = ...
  nlIntan_helper_probeChannels(chantest, bankids, chanrange, fnamefunc)

% function [ chandetect chanfiles ] = ...
%   nlIntan_helper_probeChannels(chantest, banklist, chanrange, fnamefunc)
%
% This checks for the existence of data files from specified I/O banks, and
% and probes for channels and banks if asked to do so.
%
% "chantest" is a structure with field names that are bank identifiers
%   ('A', 'B', 'DIN', etc), with each field containing an array of channel
%   numbers to test. See "CHANLIST.txt" for details.
%   An empty structure means "auto-detect all banks". An empty channel array
%   means "auto-detect all channels for this bank".
% "bankids" is a cell array containing a list of bank IDs that are
%   potentially probed.
% "chanrange" is an array of channel numbers that are potentially probed.
% "fnamefunc" points to a function that constructs a filename when passed
%   a bank ID and a channel number as arguments.
%
% "chandetect" is a structure with the same format as "chantest", enumerating
%   the banks and channels from which data was read. Fields in "chantest"
%   that are not "potentially probed" bank identifiers are copied as-is.
% "chanfiles" is an array of structures containing the following fields:
%    "bank"  - Bank identifier (field name).
%    "chan"  - Channel number.
%    "fname" - Name of the file containing this bank/channel's data.

chandetect = struct();
chanfiles = [];

% Compile a list of any bank names we've been given. If this is
% empty, we're being asked to probe for all of them.
% Copy non-probed fields while we're at it.

banklist = {};
flist = fieldnames(chantest);

for fidx = 1:length(flist)

  thisfield = flist{fidx};

  if ismember(thisfield, bankids)
    banklist{1 + length(banklist)} = thisfield;
  else
    chandetect.(thisfield) = chantest.(thisfield);
  end

end

if 1 > length(banklist)
  banklist = bankids;
end


% Walk through the list, probing for files.

for bidx = 1:length(banklist)

  thisbank = banklist{bidx};

  thischanlist = [];
  if isfield(chantest, thisbank)
    thischanlist = chantest.(thisbank);
  end

  if 1 > length(thischanlist)
    thischanlist = chanrange;
  end

  for cidx = 1:length(thischanlist)

    thischan = thischanlist(cidx);
    fname = fnamefunc(thisbank, thischan);

    if isfile(fname)
      if ~isfield(chandetect, thisbank)
        chandetect.(thisbank) = [];
      end

      detectlist = chandetect.(thisbank);
      detectlist(1 + length(detectlist)) = thischan;
      chandetect.(thisbank) = detectlist;

      thisrec = struct('bank', thisbank, 'chan', thischan, 'fname', fname);
      if (1 > length(chanfiles))
        chanfiles = thisrec;
      else
        chanfiles(1 + length(chanfiles)) = thisrec;
      end
    end

  end

end


% Done.

end

%
% This is the end of the file.
