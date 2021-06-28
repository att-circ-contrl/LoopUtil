function [ is_ok metadata ] = nlIntan_readMetadata(fname)

% function [ is_ok metadata ] = nlIntan_readMetadata(fname)
%
% This attempts to read selected parts of the specified Intan metadata file.
% If successful, "is_ok" is set to "true" and "metadata" is a structure with
% the following fields:
%
% "devtype"  - "RHS" for a recording controller, "RHD" for stimulation.
% "samprate" - Sampling rate in Hz.
%
% On failure, "is_ok" is set to "false" and "metadata" is an empty structure.
%
% FIXME - Ignoring most of the metadata. Use Intan's functions if you need
% all of it.

is_ok = false;
metadata = struct();

if isfile(fname)

  is_ok = true;

  fid = fopen(fname, 'r');

  % The file is saved as little-endian, and Matlab defaults to little-endian.
  magicnum = fread(fid, 1, 'uint32');
  version = fread(fid, 2, 'int16');
  samprate = fread(fid, 1, 'single');

  fclose(fid);

  devtype = 'unknown';

  if 0xc6912702 == magicnum
    devtype = 'RHD';
  elseif 0xd69127ac == magicnum
    devtype = 'RHS';
  else
    is_ok = false;
    disp(sprintf('Unrecognized magic number 0x"%X".', magicnum));
  end

  if is_ok
    metadata.devtype = devtype;
    metadata.samprate = samprate;
  end

else
  disp(sprintf('Unable to read from "%s".', fname));
end


% Done.

end

%
% This is the end of the file.
