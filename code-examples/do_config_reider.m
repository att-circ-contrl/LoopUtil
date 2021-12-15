% NeuroLoop Project - Test program configuration file - Reider dataset
% Written by Christopher Thomas.

%
%
% Configuration.


%
% Switches.

% Use common-average referencing instead of using the reference channel.
want_common_ref = false;



%
% Signal processing configuration.

% Ali said that driving happens in the first 4 minutes and last 2 minutes.
% Trim the first 6 and last 3, just in case.
% Actual times are shorter than Ali said for this dataset.

trimtimes = [ 360 180 ];
%trimtimes = [];  % No trimming.

% Motor driving gives a peak from 10-12 Hz.
% We're getting a broad 40-50 Hz peak that looks suspicious, but it's not
% due to the notch filter (removing that filter doesn't change the peak).



%
% Dataset configuration.

% Folders to probe.
folderlist = struct( 'reider', 'datasets/reider-20200611-02' );


% Data channels.
% The Reider recording has channels 14, 45, 47, 49, and 51 in bank A.
% Ignore channel 47; it's the reference channel.

reider_chans = [ 14 45 49 51 ];
chanlist = struct( 'reider', struct( 'ampA', ...
  struct( 'chanlist', reider_chans ) ) );

% Referencing.
% Define a common average reference and a single channel reference.

refdefs = struct( 'single', ...
  struct( 'reider', struct( 'ampA', struct( 'chanlist', 47 ) ) ), ...
  'common', ...
  struct( 'reider', struct( 'ampA', struct( 'chanlist', [0:63] ) ) ) ...
  );

desired_ref = 'single';
if want_common_ref
  desired_ref = 'common';
end

% Add reference information to the channel list.
reflist = cell(size(reider_chans));
reflist(:) = { desired_ref };
chanlist.reider.ampA.reflist = reflist;



%
% Analysis tuning parameters.

% Start with the default parameters and modify as needed.

% Get default algorithm parameters.
tuningart = nlChan_getArtifactDefaults();
tuningfilt = nlChan_getFilterDefaults();
tuningspect = nlChan_getSpectrumDefaults();
tuningperc = nlChan_getPercentDefaults();


% Adjust the trimming endpoints.
if (0 < length(trimtimes))
  tuningart.trimstart = trimtimes(1);
  tuningart.trimend = trimtimes(2);
end


% Add notch filtering for power line harmonics.
%tuningfilt.powerfreq = [ 60 120 180 ];


%
%
% This is the end of the file.
