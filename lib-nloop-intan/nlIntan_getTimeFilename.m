function fname = nlIntan_getTimeFilename(indir)

% function fname = nlIntan_getTimeFilename(indir)
%
% This returns the name of the file containing Intan signal timestamps.
% The file doesn't necessarily exist; this just constructs the filename.
% NOTE - Intan saves the sample indices, not an actual time values.
%
% "indir" is the directory to search.
%
% "fname" is the name of the file that should contain sample time indices.

fname = strcat(indir, '/time.dat');

%
% Done.

end


%
% This is the end of the file.
