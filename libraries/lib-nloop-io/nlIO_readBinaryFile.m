function [is_ok sampdata] = nlIO_readBinaryFile(fname, dtype, samprange)

% function [is_ok sampdata] = nlIO_readBinaryFile(fname, dtype, samprange)
%
% This attempts to read a packed array of the specified data type from the
% specified file.
%
% NOTE - The data is returned as-is, _not_ promoted to double.
%
% "fname" is the name of the file to read from.
% "dtype" is a string identifying the Matlab data type (e.g. 'uint32').
% "samprange" [first last] is the range of data samples (not bytes) to read,
%   specified with Matlab's conventions (the first sample is sample 1, not 0).
%   Specify an empty sample range ([]) to read all data in the file.
%
% "is_ok" is set to true if the operation succeeds and false otherwise.
% "sampdata" is an array containing the sample values, in native format.


is_ok = false;
sampdata = [];

if isfile(fname)

  is_ok = true;

  fid = fopen(fname, 'r');

  if isempty(samprange)

    % Read everything.
    % NOTE - Use "srctype=>dsttype" to force keeping the native format.
    sampdata = fread(fid, inf, [ dtype '=>' dtype ]);

    if length(sampdata) < 1
      is_ok = false;
      disp(sprintf('File "%s" contained no data.', fname));
    end

  else

    % Precompute various pieces of information.

    firstsamp = min(samprange);
    sampcount = 1 + max(samprange) - min(samprange);

    scratchfunc = str2func(dtype);
    scratchvar = scratchfunc(0);
    scratchrec = whos('scratchvar', 'var');
    bytespersamp = scratchrec.bytes;


    % Try to read the span we're interested in.

    errcode = fseek(fid, bytespersamp * (firstsamp - 1), 'bof');
    if errcode ~= 0
      is_ok = false;
      disp(sprintf('Couldn''t seek to sample %d in "%s"', firstsamp, fname));
    else
      % NOTE - Use "srctype=>dsttype" to force keeping the native format.
      sampdata = fread(fid, [ 1 sampcount ], [ dtype '=>' dtype ]);

      readcount = length(sampdata);
      if readcount ~= sampcount
        is_ok = false;
        disp(sprintf( 'Expected %d samples from "%s" but read %d.', ...
          sampcount, fname, readcount ));
      end
    end

  end

  fclose(fid);

else
  disp(sprintf('Unable to read from "%s".', fname));
end


% Done.

end

%
% This is the end of the file.
