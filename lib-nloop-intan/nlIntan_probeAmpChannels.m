function [ chandetect ampdetect chanfiles ] = ...
  nlIntan_probeAmpChannels(indir, chantest)

% function [ chandetect ampdetect chanfiles ] = ...
%   nlIntan_probeAmpChannels(indir, chantest)
%
% This checks for the existence of data files from specified amplifier
% channels, and probes for channels and amplifiers if asked to do so.
%
% "indir" is the directory to search.
% "chantest" is a structure with field names that are amplifier identifiers
%   ('A', 'B', etc), with each field containing an array of channel numbers
%   to fetch. An empty structure means "auto-detect all amplifiers". An
%   empty array in a channel field means "auto-detect all channels".
%
% "chandetect" is a structure with the same format as "chantest", enumerating
%   the amplifiers and channels from which data was read. Fields in "chantest"
%   that are not amplifier identifiers (per CHANLIST.txt) are copied as-is.
% "ampdetect" is a cell array of field names, containing only detected
%   amplifier IDs.
% "chanfiles" is an array of structures containing the following fields:
%   "bank"  - Amplifier identifier string.
%   "chan"  - Channel number.
%   "fname" - Name of the file containing this bank/channel's data.

chandetect = struct();
ampdetect = {};

bankids = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H' };
chanrange = 0:127;

fnamefunc = @(thisbank, thischan) ...
  nlIntan_getAmpChannelFilename(indir, thisbank, thischan);


% Wrap the helper function.

[ chandetect chanfiles ] = ...
  nlIntan_helper_probeChannels( chantest, bankids, chanrange, fnamefunc );


% Copy the list of detected amplifiers.

flist = fieldnames(chandetect);
for fidx = 1:length(flist)
  thisfield = flist{fidx};
  if ismember(thisfield, bankids)
    ampdetect{1 + length(ampdetect)} = thisfield;
  end
end


% Done.

end

%
% This is the end of the file.
