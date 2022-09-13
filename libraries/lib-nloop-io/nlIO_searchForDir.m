function dirs_found = nlIO_searchForDir( startdir, targetname )

% function dirs_found = nlIO_searchForDir( startdir, targetname )
%
% This searches a directory tree for folders that match the specified name.
% This wraps "dir", so the folder name can contain wildcards.
%
% "startdir" is the top-level folder to look in.
% "targetname" is the folder name to match. This is passed to "dir", so it
%   can contain wildcards.
%
% "dirs_found" is a cell array containing paths to folders that match the
%   target name.


dirs_found = {};

% NOTE - This only lists the _contents_ of the target, not the target
% itself. So, we'll get one or more entries with the target as the path,
% for each matching target.

dirlist = dir([ startdir filesep '**' filesep targetname ]);

% Everything in the array should be a valid match.
if ~isempty(dirlist)
  dirs_found = [ dirs_found { dirlist.folder } ];
end

% Reduce to only one entry per match.
dirs_found = unique(dirs_found);


% Done.

end


%
% This is the end of the file.
