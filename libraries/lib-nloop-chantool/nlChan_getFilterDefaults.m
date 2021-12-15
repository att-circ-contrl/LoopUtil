function paramstruct = nlChan_getFilterDefaults()

% function paramstruct = nlChan_getFilterDefaults()
%
% This returns a structure containing reasonable default tuning parameters
% for signal filtering.
%
% Parameters that will most often be varied are "powerfreq" and "lfprate".


paramstruct = struct( ...
  'lfprate', 2000, 'lfpcorner', 200, 'powerfreq', 60.0, 'dcfreq', 2.0 );


%
% Done.

end


%
% This is the end of the file.
