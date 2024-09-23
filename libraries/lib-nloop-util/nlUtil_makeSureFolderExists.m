function nlUtil_makeSureFolderExists( target )

% function nlUtil_makeSureFolderExists( target )
%
% This checks to see if the folder containing the target exists, and creates
% it if it doesn't. The target file itself does not have to exist.
%
% This is intended to be called before creating the target file, so that
% files can be created in folder trees.
%
% "target" is either a filename (without trailing folder separator) or a
%   folder name (with trailing folder separator).
%
% No return value.


[ fpath fname fext ] = fileparts(target);

if ~isempty(fpath)
  % Check that the parent folder, if any, exists.
  nlUtil_makeSureFolderExists(fpath);

  % Check that the leaf folder exists, and create it if it doesn't.
  if ~isfolder(fpath)
    mkdir(fpath);
  end
end


% Done.
end


%
% This is the end of the file.
