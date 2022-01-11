function [ isok newmeta ] = ...
  nlIO_readFolderMetadata( oldmeta, newlabel, indir, devicetype )

% function [ isok newmeta ] = ...
%   nlIO_readFolderMetadata( oldmeta, newlabel, indir, devicetype )
%
% This probes the specified directory, looking for data and metadata files
% from the specified type of ephys machine or software suite. If the type
% is given as 'auto', this searches for types that it knows how to identify.
%
% Metadata structure format is defined in "FOLDERMETA.txt".
%
% "oldmeta" is a project metadata structure to add to. Pass an empty structure
%   to create a new project metadata structure.
% "newlabel" is used as a folder label for adding this folder's metadata to
%   the project metadata structure.
% "indir" is the directory to search.
% "devicetype" is a character array specifying the type of architecture to
%   look for. Known types are 'intan' and 'openephys'. Use 'auto' for
%   automatic detection.
%
% "isok" is true if folder metadata was successfully read and false otherwise.
% "newmeta" is a copy of "oldmeta" with new folder metadata added. If no new
%   metadata was found, a copy of "oldmeta" is still returned. If metadata
%   from multiple devices is found, multiple folder metadata structures are
%   added. "makeUniqueStrings" is called to avoid folder label conflicts.


%
% Initialize output and handle the "new structure" case.

isok = false;
newmeta = oldmeta;
if isempty(newmeta) || (~isstruct(newmeta))
  newmeta = struct();
end
if ~isfield(newmeta, 'folders')
  newmeta.folders = struct();
end


%
% Parse name types that we know about.

want_intan = false;
want_openephys = false;

if strcmpi('intan', devicetype)

  want_intan = true;

elseif strcmpi('openephys', devicetype)

  want_openephys = true;

elseif strcmpi('auto', devicetype)

  % All known devices.
  want_intan = true;
  want_openephys = true;

else
  % FIXME - Diagnostics.
  disp(sprintf( '[nlIO_readFolderMetadata]  Unknown device type "%s".', ...
    devicetype ));
end


%
% Initialize the new folder list.

foldercount = 0;
folderlabels = {};
newfolders = {};


%
% Detect folders of known types.

if want_intan
  % This returns an empty struct if it didn't find anything.
  thisfolder = nlIntan_probeFolder(indir);

  if ~isempty(fieldnames(thisfolder))
    % Queue this folder's metadata to be added.
    foldercount = foldercount + 1;
    folderlabels{foldercount} = newlabel;
    newfolders{foldercount} = thisfolder;
  end
end

if want_openephys
  % This returns an empty struct if it didn't find anything.
  thisfolder = nlOpenE_probeFolder(indir);

  if ~isempty(fieldnames(thisfolder))
    % Queue this folder's metadata to be added.
    foldercount = foldercount + 1;
    folderlabels{foldercount} = newlabel;
    newfolders{foldercount} = thisfolder;
  end
end


%
% Add the new folders, with unique names.

folderlabels = ...
  matlab.lang.makeUniqueStrings( folderlabels, fieldnames(newmeta.folders) );
for fidx = 1:foldercount
  newmeta.folders.(folderlabels{fidx}) = newfolders{fidx};
end

% Set the success flag.
isok = (foldercount > 0);


% Done.

end


%
% This is the end of the file.
