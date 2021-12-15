function paramstruct = nlChan_getArtifactDefaults()

% function paramstruct = nlChan_getArtifactDefaults()
%
% This returns a structure containing reasonable default tuning parameters
% for artifact rejection.
%
% Parameters that will most often be varied are "ampthresh", "diffthresh",
% "trimstart", and "trimend".


paramstruct = struct( ...
  'trimstart', 0, 'trimend', 0, ...
  'ampthresh', 6, 'amphalo', 3, 'diffthresh', 8, 'diffhalo', 3, ...
  'timehalosecs', 0.1, 'smoothsecs', 0.01, 'dcsecs', 3 );


%
% Done.

end


%
% This is the end of the file.
