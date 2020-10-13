function fname = nlIntan_getAmpChannelFilename(indir, bankid, channum)

% function fname = nlIntan_getAmpChannelFilename(indir, bankid, channum)
%
% This returns the data file name for the specified Intan amplifier channel.
% This file doesn't necessarily exist; this just constructs the name.
%
% "indir" is the directory containing Intan data.
% "bankid" is the bank label for the desired channel.
% "channum" is the in-bank channel number for the desired channel.
%
% "fname" is the name of the file that should contain the channel's data.
% This is an empty character array if an error occurred.

fname = '';

% Field names and filename labels are the same for amp-X-nnn.
ampnamelut = struct( 'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D', ...
  'E', 'E', 'F', 'F', 'G', 'G', 'H', 'H' );
chanlimits = [ 0 127 ];

if isfield(ampnamelut, bankid) ...
  && (channum >= min(chanlimits)) && (channum <= max(chanlimits))
  fname = sprintf('%s/amp-%s-%03d.dat', indir, bankid, channum);
end

%
% Done.

end


%
% This is the end of the file.
