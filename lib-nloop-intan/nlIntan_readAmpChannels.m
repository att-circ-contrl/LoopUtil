function [is_ok chandetect ampdetect timedata chandata] = ...
  nlIntan_readAmpChannels(indir, chanlist)

% function [is_ok chandetect ampdetect timedata chandata] = ...
%   nlIntan_readAmpChannels(indir, chanlist)
%
% This attempts to read individual Intan amplifier channel data files from
% the specified directory. The time series is also read.
%
% "indir" is the directory to search.
% "chanlist" is a structure with field names that are amplifier identifiers
%   ('A', 'B', etc), with each field containing an array of channel numbers
%   to fetch. An empty structure means "auto-detect all amplifiers". An
%   empty array in a channel field means "auto-detect all channels".
%
% "is_ok" is true if data was read and false otherwise.
% "chandetect" is a structure with the same format as "chanlist", enumerating
%   the amplifiers and channels from which data was read.
% "timedata" contains the time series (in samples, not seconds).
% "chandata" is an array of structures containing the following fields:
%   "bank" - Amplifier identifier string.
%   "chan" - Channel number.
%   "fname" - Filename.
%   "data" - Sample data series.

is_ok = true;
timedata = [];
chandata = [];


% First, probe for amplifiers and channels that are present.
[chandetect ampdetect chanfiles] = nlIntan_probeAmpChannels(indir, chanlist);


% Next, read the detected channels, and the time series.
% NOTE - These are returned in native format, not scaled.

[ is_ok timedata ] = ...
  nlIO_readBinaryFile(strcat(indir, '/time.dat'), 'int32');

for fidx = 1:length(chanfiles)
  if is_ok

    thisrec = chanfiles(fidx);

    if isfile(thisrec.fname)
      [is_ok thisdata] = nlIO_readBinaryFile(thisrec.fname, 'int16');

      if is_ok
        thisrec.data = thisdata;

        if 1 > length(chandata)
          chandata = thisrec;
        else
          chandata(1 + length(chandata)) = thisrec;
        end
      end
    end

  end
end


if ~is_ok
  chandetect = chanlist;
  ampdetect = {};
  timedata = [];
  chandata = [];
end


% Done.

end

%
% This is the end of the file.
