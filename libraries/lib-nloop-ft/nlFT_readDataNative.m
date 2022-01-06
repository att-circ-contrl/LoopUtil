function data = ...
  nlFT_readDataNative( indir, header, firstsample, lastsample, chanidxlist )

% function data = ...
%   nlFT_readDataNative( indir, header, firstsample, lastsample, chanidxlist )
%
% This probes the specified directory using nlIO_readFolderMetadata(), and
% reads all appropriate signal data into a Field Trip data matrix.
%
% The "Native" version of this function keeps data as its native type.
%
% NOTE - This returns monolithic data (a 2D matrix), not epoched data.
% NOTE - This requires all selected banks to have the same sampling rate and
% number of samples!
% NOTE - This requires all selected banks to have compatible types! The first
% channel processed determines the returned type. For best results, make sure
% all selected banks have the _same_ type.
%
% This calls nlFT_testWantChannel() and nlFT_testWantBank() and only reads
% channels that are wanted. By default all channels and banks are wanted;
% use nlFT_selectChannels() to change this.
%
% If directory probing fails, and error is thrown.
%
% "indir" is the directory to process.
% "header" is the Field Trip header associated with this directory.
% "firstsample" is the index of the first sample to read.
% "lastsample" is the index of the last sample to read.
% "chanidxlist" is a vector containing channel indices to read.
%
% "data" is the resulting 2D data matrix.


% Wrap the helper function.

wantnative = true;
data = nlFT_readData_helper( indir, wantnative, ...
  header, firstsample, lastsample, chanidxlist );


% Done.

end


%
% This is the end of the file.
