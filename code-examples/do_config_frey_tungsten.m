% NeuroLoop Project - Test program configuration file - Frey tungsten dataset
% Written by Christopher Thomas.

%
%
% Configuration.


%
% Switches.

want_unity = false;
want_trim = false;

% Recording channels can be referenced to common average, or to the ground
% channel average, or to the lumped signal and ground average, or to nothing
% (cable reference only).

%frey_rec_ref = 'none';
%frey_rec_ref = 'refrecord';
frey_rec_ref = 'refgnd';
%frey_rec_ref = 'refall';


%
% Signal processing configuration.

% Make a guess at when driving happens.
% Ali's data drove during the first 4 minutes and last 2 minutes.
% Motor driving gives a peak from 10-12 Hz.

trimtimes = [];  % No trimming.
if want_trim
  % Trim the first 6 and last 3 minutes.
  trimtimes = [ 360 180 ];
end



%
% Dataset configuration.

% Folders to probe.
folderlist = struct( ...
  'FreyRec', 'datasets/20211112-frey-tungsten/record_211112_112922', ...
  'FreyStim', 'datasets/20211112-frey-tungsten/stim_211112_112924' );

if want_unity
  folderlist.FreyUnity = ...
'datasets/20211112-frey-tungsten/Session4__12_11_2021__11_29_57/RuntimeData/';
end


% Data channels.
% The Reider recording has channels 14, 45, 47, 49, and 51 in bank A.
% Documentation for the test says A45 was CD, A47 was CD, elec11 was ACC.
% Cable reference was connected to the guide tube; no channel reference.
% Channels 14, 49, and 51 were grounded and used for artifact monitoring.

tungsten_chans_rec = [ 45 47 ];
tungsten_chans_recgnd = [ 14 49 51 ];
tungsten_chans_stim = [ 11 ];

% NOTE - We don't need to list the ground channels here.
% Reference-building and signal processing are done in separate passes.
chanlist = struct( ...
  'FreyRec', struct( ...
    'ampA', struct( 'chanlist', tungsten_chans_rec ), ...
    'Din', struct( 'chanlist', [1:16] ), ...
    'Dout', struct( 'chanlist', [1:16] ) ), ...
  'FreyStim', struct( ...
    'ampC', struct( 'chanlist', tungsten_chans_stim ), ...
    'Din', struct( 'chanlist', [1:16] ), ...
    'Dout', struct( 'chanlist', [1:16] ) ) );


% Referencing.
% Define average references for signals and for ground channels.
% FIXME - No reference for the stimulator!
% Hope that the cable reference is good enough.

refdefs = struct( ...
  'refrecord', struct( 'FreyRec', struct( 'ampA', ...
    struct( 'chanlist', tungsten_chans_rec ) ) ), ...
  'refgnd', struct( 'FreyRec', struct( 'ampA', ...
    struct( 'chanlist', tungsten_chans_recgnd ) ) ), ...
  'refall', struct( 'FreyRec', struct( 'ampA', ...
    struct( 'chanlist', [ tungsten_chans_rec tungsten_chans_recgnd ] ) ) ) ...
  );


% Our selected reference may be 'none'; if that's the case, don't store one.

if isfield(refdefs, frey_rec_ref)
  reflist = cell(size( chanlist.FreyRec.ampA.chanlist ));
  reflist(:) = { frey_rec_ref };
  chanlist.FreyRec.ampA.reflist = reflist;
end

% NOTE - We have no useful reference for the stimulation controller.



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
