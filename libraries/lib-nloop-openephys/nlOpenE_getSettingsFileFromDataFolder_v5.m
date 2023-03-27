function settingsname = ...
  nlOpenE_getSettingsFileFromDataFolder_v5( foldername )

% function settingsname = ...
%   nlOpenE_getSettingsFileFromDataFolder_v5( foldername )
%
% This parses an Open Ephys experiment folder path (the folder containing
% "structure.oebin"), and infers the path and filename of the corresponding
% "settings.xml" or "settingsN.xml" file.
%
% In Open Ephys v0.5, the "structure.oebin" file is in a folder named
% "experimentX/recordingY/", and the settings files are in the same folder
% that contains the "experimentX" subfolders. For "experiment1", the settings
% file is named "settings.xml". For other "experimentX" folders, the settings
% files are named "settings_X.xml".
%
% "foldername" is the full path of the folder containing "structure.oebin".
%
% "settingsname" is the full path of the appropriate settings XML file.
%   If parsing failed, this is an empty character array.


settingsname = '';


tokenlist = regexp( foldername, '(.*)experiment(\d+)', 'tokens' );

% This should only match once.
if ~isempty(tokenlist)
  settingspath = tokenlist{1}{1};
  experimentnum = str2num( tokenlist{1}{2} );

  % The path already includes the trailing file separator.

  if experimentnum > 1
    settingsname = ...
      [ settingspath 'settings_' num2str( experimentnum, '%d' ) '.xml' ];
  else
    settingsname = [ settingspath 'settings.xml' ];
  end
end


% Done.
end


%
% This is the end of the file.
