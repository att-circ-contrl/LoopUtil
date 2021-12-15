function paramstruct = nlChan_getSpectrumDefaults()

% function paramstruct = nlChan_getSpectrumDefaults()
%
% This returns a structure containing reasonable default tuning parameters
% for persistence spectrum generation.


paramstruct = struct( ...
  'freqlow', 2, 'freqhigh', 200, 'freqsperdecade', 30, ...
  'winsecs', 1.0, 'winsteps', 4 );


%
% Done.

end


%
% This is the end of the file.
