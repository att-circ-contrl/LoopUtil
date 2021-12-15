function paramstruct = nlChan_getPercentDefaults()

% function paramstruct = nlChan_getPercentDefaults()
%
% This returns a structure containing reasonable default tuning parameters
% for spike and burst identification via percentile binning.
%
% Parameters that will most often be varied are "burstselectidx" and
% "spikeselectidx".


paramstruct = struct( ...
  'burstrange', [ 0.2 0.5 1 2 5 ], 'burstselectidx', 3, ...
  'spikerange', [ 0.003 0.01 0.03 0.1 0.3 ], 'spikeselectidx', 3 );


%
% Done.

end


%
% This is the end of the file.
