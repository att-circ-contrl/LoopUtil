function [is_ok sampdata] = nlIO_readBinaryFile(fname, dtype)

% function [is_ok sampdata] = nlIO_readBinaryFile(fname, dtype)
%
% This attempts to read a packed array of the specified data type from the
% specified file. NOTE - The data is returned as-is, _not_ promoted to double.
%
% "fname" is the name of the file to read from.
% "dtype" is a string identifying the Matlab data type (e.g. 'uint32').
%
% "is_ok" is set to true if the operation succeeds and false otherwise.
% "sampdata" is an array containing the sample values, in native format.


is_ok = false;
sampdata = [];

if isfile(fname)

  is_ok = true;

  fid = fopen(fname, 'r');
  % NOTE - Use "srctype=>dsttype" to force keeping the native format.
  sampdata = fread(fid, inf, [ dtype '=>' dtype ]);
  fclose(fid);

  if (1 > length(sampdata))
    is_ok = false;
    disp(sprintf('File "%s" contained no data.', fname));
  end

else
  disp(sprintf('Unable to read from "%s".', fname));
end


% Done.

end

%
% This is the end of the file.
