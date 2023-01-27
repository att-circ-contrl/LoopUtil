function is_ok = nlIO_writeBinaryFile(fname, sampdata, dtype)

% function is_ok = nlIO_writeBinaryFile(fname, sampdata, dtype)
%
% This attempts to write the specified sample data as a packed array of the
% specified data type. Per fwrite(), data is rounded and saturated if
% appropriate.
%
% "fname" is the name of the file to write to.
% "sampdata" is an array containing the sample values.
% "dtype" is a string identifying the Matlab data type (e.g. 'uint32').
%
% "is_ok" is set to true if the operation succeeds and false otherwise.


is_ok = true;

sampcount = length(sampdata);

fid = fopen(fname, 'w');

if 0 > fid
  disp(sprintf('Unable to write to "%s".', fname));
  is_ok = false;
else

  writecount = 0;
  if 0 < sampcount
    writecount = fwrite(fid, sampdata, dtype);
  end

  fclose(fid);

  if writecount ~= sampcount
    disp(sprintf( 'Incomplete write to "%s" (%d of %d samples).', ...
      fname, writecount, sampcount ));
    is_ok = false;
  end

end


% Done.

end

%
% This is the end of the file.
