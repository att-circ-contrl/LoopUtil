% NeuroLoop Project - Channel evaluation - GUI.
% Written by Christopher Thomas.

%
% Library paths.

addPathsLoopUtil;



%
%
% Configuration.


% Behavior switches.

global want_notch_harmonics;
want_notch_harmonics = true;

% Testing: Configuration values for Ali's dataset.
want_ali_defaults = false;


% Defaults for variables that aren't set elsewhere.

defaultindir = '.';
defaultrefchanbanks = struct();

% FIXME - Adjust config values for use with Ali's dataset.
if want_ali_defaults
  defaultrefchanbanks = struct( 'ampA', struct( 'chanlist', 47 ) );
  trimtimes_ali = [ 360 180 ];
end


% Channel selection for Intan systems.
chanfilter_intan = struct( 'keepbanks', {{ 'amp\w' }} );



%
%
% Global variables.


%
% GUI elements.
% Each different set of controls has a different parent grid.

global guifig;


% UI for selecting the dataset, setting references, etc.

global setupgrid;

global setupdir;
global setupprocbutton;

global refpanel;
global refgrid;


% UI for configuring processing parameters.

global configprocgrid;

global configlfpratemsg;
global configlfphighmsg;
global configlfplowmsg;
global configpowermsg;
global configartifactmsg;

global configlfprateslider;
global configlfphighslider;
global configlfplowslider;
global configpowerhzslider;
global configpowerharmcheck;
global configartifactslider;


% UI for processing progress reports and results.

global processgrid;

global processbanner;
global processspikechan;
global processburstchan;
global processspikeplot;
global processburstplot;

global processspikeslider;
global processburstslider;
global processsortspikebutton;
global processsortburstbutton;
global processbackbutton;


% UI for sorting channels by spike activity.

global spikegrid;


% UI for sorting channels by burst activity.

global burstgrid;

global burstbandlabel;
global burstlowslider;
global bursthighslider;
global burstwidebutton;

global burstplotrelative;
global burstplotspect;
global burstgridrelative;
global burstgridspect;
global burstplotonebutton;
global burstplottypebutton;

global burstdatadirlabel;
global burstplotdirlabel;
global burstplotallbutton;
global burstsaveallbutton;
global burstresultlist;



%
% Other global variables.

% Configuration values.

global indir;
global refchans;
global metadata;
global folderlabel;
global chanfilter;

global have_metadata;
global have_bankrefs;
global bankrefs;

have_metadata = false;
have_bankrefs = false;

global tuningart;
global tuningfilt;
global tuningspect;
global tuningperc;

global burst_want_persist;
global burst_show_relative;
global burst_datadir;
global burst_plotdir;

folderlabel = 'datafolder';
% FIXME - Hardcoding Intan conventions.
chanfilter = chanfilter_intan;

burst_want_persist = false;
burst_show_relative = true;
burst_datadir = '';
burst_plotdir = '';


% GUI housekeeping variables.

global have_ref_grid;
global did_band_init;

have_ref_grid = false;
did_band_init = false;


% State values.

global probechans;
global refchansdefault;  % Global copy of the non-global config above.
global channelstats;
global lfpfreqsteps;



%
%
% Main program.


%
% Set configuration variables to starting values.

indir = defaultindir;
refchans = struct();
refchans.(folderlabel) = defaultrefchanbanks;

tuningart = nlChan_getArtifactDefaults();
tuningfilt = nlChan_getFilterDefaults();
tuningspect = nlChan_getSpectrumDefaults();
tuningperc = nlChan_getPercentDefaults();


% Add notch filtering for power line harmonics, if requested.
% FIXME - This gets overwritten as soon as the GUI starts up.
if want_notch_harmonics
  basefreq = 60;
  if (0 < length(tuningfilt.powerfreq))
    basefreq = tuningfilt.powerfreq(1);
  end

  tuningfilt.powerfreq = [ basefreq 2*basefreq 3*basefreq ];
end


% FIXME - Adjust config values for use with Ali's dataset, if requested.
if want_ali_defaults
  tuningart.trimstart = trimtimes_ali(1);
  tuningart.trimend = trimtimes_ali(2);
end



%
% Initialize state to safe values.

probechans = struct();
refchansdefault = struct();
refchansdefault.(folderlabel) = defaultrefchanbanks;



%
% Bring up the GUI.

guiConstructGUI();



% Nothing else to do; the application runs in its own thread.


%
% Done.



%
%
% Data processing functions.


% This initiates processing of a dataset.
% The directory and configuration parameters should be valid; they're
% checked by their various input routines.

function helper_runProcessing()

  global indir;
  global refchans;
  global metadata;
  global probechans;

  global have_metadata;
  global have_bankrefs;
  global bankrefs;

  global tuningart;
  global tuningfilt;
  global tuningspect;
  global tuningperc;

  global channelstats;

  global processspikechan;
  global processburstchan;
  global processspikeplot;
  global processburstplot;


  %
  % Clear the plots.

  cla(processspikeplot, 'reset');
  cla(processburstplot, 'reset');

  guiMakeAxesNonInteractive( processspikeplot );
  guiMakeAxesNonInteractive( processburstplot );

  drawnow;


  %
  % Make sure we have metadata.

  is_ok = have_metadata;


  %
  % Rebuild references.

  if is_ok && (~have_bankrefs)

    guiSetProcessingMessage('Rebuilding references.');

    % NOTE - This will leave us with an empty structure if no references
    % were configured by the user.
    bankrefs = struct();
    have_bankrefs = true;

    % NOTE - Our power scale expects uV rather than V, so multiply by 1e+6.
    refprocfunc = @( metadata, folderid, bankid, chanid, ...
      wavedata, timedata, wavenative, timenative ) ...
      helper_processReference( metadata, folderid, bankid, chanid, ...
        wavedata * 1e+6, tuningart );

    % NOTE - The processing function modifies the global "bankrefs" variable.
    % We don't need to save any results from processing.

    % FIXME - Hardcoding number of simultaneous channels in memory.
    refbadfrac = nlIO_iterateChannels( metadata, refchans, 1, refprocfunc );

  end


  %
  % Iterate channel by channel.

  if is_ok

    guiSetProcessingMessage('Reading channel data.');

    % Make sure to omit the reference channels here.
    signalchans = nlIO_subtractFromChanList(probechans, refchans);

    % NOTE - Our power scale expects uV rather than V, so multiply by 1e+6.
    procfunc = @( metadata, folderid, bankid, chanid, ...
      wavedata, timedata, wavenative, timenative ) ...
      helper_processChannel( metadata, folderid, bankid, chanid, ...
      wavedata * 1e+6, ...
      bankrefs, tuningart, tuningfilt, tuningspect, tuningperc );

    % FIXME - Hardcoding number of simultaneous channels in memory.
    channelstats = nlIO_iterateChannels( metadata, signalchans, 1, procfunc );

  end


  %
  % Process the results (getting desired channels and plotting).

  if is_ok

    guiSetProcessingMessage('Sorting and plotting...');

    spikerange = tuningperc.spikerange;
    burstrange = tuningperc.burstrange;
    spikepidx = tuningperc.spikeselectidx;
    burstpidx = tuningperc.burstselectidx;

    % NOTE - Remember that we want negative skew for spikes.
    spike_scorefunc = @(thisrec) - thisrec.spikeskew(spikepidx);
    % NOTE - Our preliminary burst ranking doesn't do band filtering.
    burst_scorefunc = @(thisrec) max(thisrec.spectskew{burstpidx});

    [ sp_best sp_typbest sp_typmid sp_typworst ] = ...
      nlChan_rankChannels(channelstats, inf, 0.1, spike_scorefunc);
    [ bu_best bu_typbest bu_typmid bu_typworst ] = ...
      nlChan_rankChannels(channelstats, inf, 0.1, burst_scorefunc);


    % Only make plots if we actually had data.

    if (~isempty(sp_best)) && (~isempty(bu_best))
      % Plot the typical best cases.
      % NOTE - The absolute best might be outliers, so plot typical instead.

      processspikechan.Text = ...
        sprintf( 'Typ. spikes:  %s - %03d', sp_typbest.bank, sp_typbest.chan );
      processburstchan.Text = ...
        sprintf( 'Typ. bursts:  %s - %03d', bu_typbest.bank, bu_typbest.chan );

      drawnow;

      nlPlot_axesPlotSpikeHist( processspikeplot, ...
        sp_typbest.result.spikebincounts, sp_typbest.result.spikebinedges, ...
        sp_typbest.result.spikepercentvals / sp_typbest.result.spikeiqr, ...
        tuningperc.spikerange, '' );

      guiMakeAxesNonInteractive( processspikeplot );

      nlPlot_axesPlotExcursions( processburstplot, ...
        bu_typbest.result.spectfreqs, bu_typbest.result.spectmedian, ...
        bu_typbest.result.spectiqr, bu_typbest.result.spectskew, ...
        tuningperc.burstrange, true, '' );

      guiMakeAxesNonInteractive( processburstplot );
    end

  end


  %
  % Done.

  if is_ok
    guiSetProcessingMessage('Finished processing.');
    guiToggleProcessButtons(true);
  end

end



% This is a scoring function for bursts that squashes out-of-band events.
% "skewlist" is an array of per-frequency skew values. We want high ones.
% "freqlist" is an array of frequencies corresponding to the above.
% "bandlimits" [min max] specifies the frequency range to accept.
% This returns a score, or NaN if there are no in-band frequencies.

function scoreval = helper_scoreBurstInBand(skewlist, freqlist, bandlimits)

  freqidx = (freqlist >= min(bandlimits)) & (freqlist <= max(bandlimits));
  freqlist = freqlist(freqidx);
  skewlist = skewlist(freqidx);

  scoreval = NaN;
  if (0 < length(skewlist))
    % Pick the highest skew and use that as the score.
    scoreval = max(skewlist);
  end

end



% This is a wrapper for reference processing that performs artifact rejection.

function resultval = helper_processReference( ...
  metadata, folderid, bankid, chanid, wavedata, tuningart )

  global bankrefs;

  guiSetProcessingMessage(sprintf( 'Processing bank %s chan %03d ...', ...
    bankid, chanid ));

  samprate = metadata.folders.(folderid).banks.(bankid).samprate;

  % Do artifact rejection and trimming.
  % Keep NaN values where artifacts were removed.

  [ refseries fracbad ] = nlChan_applyArtifactReject( ...
    wavedata, [], samprate, tuningart, true );

  % FIXME - Store the reference even if it was mostly artifacts.
  bankrefs.(bankid) = refseries;

  % Return the artifact fraction, in case we do want to filter on that.
  resultval = fracbad;

end



% This is a wrapper for channel processing that includes a progress banner.

function resultval = helper_processChannel( ...
  metadata, folderid, bankid, chanid, wavedata, ...
  bankrefs, tuningart, tuningfilt, tuningspect, tuningperc )

  guiSetProcessingMessage(sprintf( 'Processing bank %s chan %03d ...', ...
    bankid, chanid ));

  samprate = metadata.folders.(folderid).banks.(bankid).samprate;

  % If we have a reference, use it; otherwise don't re-reference.
  refdata = [];
  if isfield(bankrefs, bankid)
    refdata = bankrefs.(bankid);
  end

  resultval = nlChan_processChannel( wavedata, samprate, ...
    refdata, tuningart, tuningfilt, tuningspect, tuningperc );

end



% This returns an array of logarithmically spaced "clean-looking" frequency
% steps that fall within the specified range.
% NOTE - We're using something that's almost but not quite the E6 series,
% that matches the canonical neural frequency bands.

function steplist = helper_getFreqSteps(lowfreq, highfreq)

  hundred_lut = [ 1 1.5 2 3 4 6 8 12.5 16 25 35 50 70 ];

  % This puts "1*100^exp" below or equal to the specified value.
  % For highfreq, that still guarantees that "100*100^exp" would be above it.
  expmin = floor(0.5 * log10(lowfreq));
  expmax = floor(0.5 * log10(highfreq));

  steplist = [];

  for expidx = expmin:expmax
    for lidx = 1:length(hundred_lut)

      thisval = hundred_lut(lidx) * 100^expidx;

      if (thisval >= lowfreq) && (thisval <= highfreq)
        steplist(1 + length(steplist)) = thisval;
      end

    end
  end

end



% This formats a number with variable precision (no trailing zeroes).
% FIXME - The maximum number of trailing digits is hard-coded.

function resultstr = helper_formatSmartPrecision(inputnum)

  precdigits = 6;
  done = false;

  while (0 < precdigits) && (~done)
    thisval = round(inputnum * 10^precdigits);

    if 0 == mod(thisval, 10)
      precdigits = precdigits - 1;
    else
      done = true;
    end
  end

  formatstr = sprintf('%%.%df', precdigits);
  resultstr = sprintf(formatstr, inputnum);

end



% This saves plots for one result case.

function helper_saveOnePlot(thisfig, thisrec)

  global tuningperc;

  global burst_want_persist;
  global burst_plotdir;


  fileprefix = sprintf( '%s/burst-%s-%03d', ...
    burst_plotdir, thisrec.bank, thisrec.chan' );
  casestring = sprintf( '%s %03d', thisrec.bank, thisrec.chan );

  nlPlot_plotExcursions( thisfig, ...
    sprintf( '%s-excursions.png', fileprefix ), ...
    thisrec.result.spectfreqs, thisrec.result.spectmedian, ...
    thisrec.result.spectiqr, thisrec.result.spectskew, ...
    tuningperc.burstrange, true, ...
    sprintf( '%s - Power Excursions', casestring ) );

  nlPlot_plotExcursions( thisfig, ...
    sprintf( '%s-spect.png', fileprefix ), ...
    thisrec.result.spectfreqs, thisrec.result.spectmedian, ...
    thisrec.result.spectiqr, thisrec.result.spectskew, ...
    tuningperc.burstrange, false, ...
    sprintf( '%s - Power Spectrum', casestring ) );

  if burst_want_persist
    nlPlot_plotPersist( thisfig, ...
      sprintf( '%s-persist.png', fileprefix ), ...
      thisrec.result.persistvals, thisrec.result.persistfreqs, ...
      thisrec.result.persistpowers, true, ...
      sprintf( '%s - Persistence Spectrum', casestring ) );
  end

end



%
%
% GUI management functions.


% This builds the GUI window and its control sets.

function guiConstructGUI()

  %
  % Configuration and state variables we need to access.

  global tuningart;
  global tuningperc;

  global want_notch_harmonics;


  %
  % Parent figure.

  global guifig;

  guifig = uifigure( 'Name', 'NeuroLoop Channel Tool' );


  %
  % "Setup" control panel.

  global setupgrid;

  global setupdir;
  global setupprocbutton;
  global refpanel;

  setupgrid = uigridlayout( guifig, [ 6 1 ] );
  setupgrid.RowHeight = { '1x', '1x', '2x', '6x', '1x', '1x' };

  ctl = uibutton( setupgrid, 'Text', 'Select Data Directory', ...
    'FontWeight', 'bold', 'ButtonPushedFcn', {@callback_selectDir} );
  setupdir = uilabel( setupgrid, 'Text', 'No directory selected.' );

  tmpgrid = uigridlayout( setupgrid, [ 1 4 ] );
  ctl = uilabel( tmpgrid, 'Text', 'Start trim (sec):', ...
    'FontWeight', 'bold' );
  ctl = uieditfield( tmpgrid, 'numeric', ...
    'Value', tuningart.trimstart, 'Limits', [ 0 inf ], ...
    'ValueChangedFcn', {@callback_editTrimStart} );
  ctl = uilabel( tmpgrid, 'Text', 'End trim (sec):', ...
    'FontWeight', 'bold' );
  ctl = uieditfield( tmpgrid, 'numeric', ...
    'Value', tuningart.trimend, 'Limits', [ 0 inf ], ...
    'ValueChangedFcn', {@callback_editTrimEnd} );

  refpanel = uipanel( setupgrid, 'Title', 'References', ...
    'FontWeight', 'bold' );
  guiMakeNewRefGrid();

  ctl = uibutton( setupgrid, 'Text', 'Edit Processing Config', ...
    'ButtonPushedFcn', {@callback_editProcConfig} );

  setupprocbutton = uibutton( setupgrid, 'Text', 'Process', ...
    'Enable', 'off', 'ButtonPushedFcn', {@callback_startProcess} );

  setupgrid.Visible = 'off';


  %
  % "Configure Processing" control panel.

  global configprocgrid;

  global configlfpratemsg;
  global configlfphighmsg;
  global configlfplowmsg;
  global configpowermsg;
  global configartifactmsg;

  global configlfprateslider;
  global configlfphighslider;
  global configlfplowslider;
  global configpowerhzslider;
  global configpowerharmcheck;
  global configartifactslider;

  configprocgrid = uigridlayout( guifig, [ 11 2 ] );
  configprocgrid.RowHeight = ...
    { '1x', '2x', '1x', '2x', '1x', '2x', '1x', '2x', '1x', '2x', '1x' };
  configprocgrid.ColumnWidth = { '2x', '1x' };

  configlfpratemsg = uilabel( configprocgrid, 'Text', '', ...
    'FontWeight', 'bold' );
  configlfpratemsg.Layout.Column = [ 1 2 ];
  configlfprateslider = uislider( configprocgrid, ...
    'ValueChangedFcn', {@callback_procConfigSliderChanged} );
  guiConfigSlider( configlfprateslider, [ 500 1000 2000 ], 3, '%d' );
  configlfprateslider.Layout.Column = [ 1 2 ];

  configlfphighmsg = uilabel( configprocgrid, 'Text', '', ...
    'FontWeight', 'bold' );
  configlfphighmsg.Layout.Column = [ 1 2 ];
  configlfphighslider = uislider( configprocgrid, ...
    'ValueChangedFcn', {@callback_procConfigSliderChanged} );
  guiConfigSlider( configlfphighslider, [ 50 100 200 ], 3, '%d' );
  configlfphighslider.Layout.Column = [ 1 2 ];

  configlfplowmsg = uilabel( configprocgrid, 'Text', '', ...
    'FontWeight', 'bold' );
  configlfplowmsg.Layout.Column = [ 1 2 ];
  configlfplowslider = uislider( configprocgrid, ...
    'ValueChangedFcn', {@callback_procConfigSliderChanged} );
  guiConfigSlider( configlfplowslider, [ 0.2 0.5 1 2 5 ], 4, '%.1f' );
  configlfplowslider.Layout.Column = [ 1 2 ];

  configpowermsg = uilabel( configprocgrid, 'Text', '', ...
    'FontWeight', 'bold' );
  configpowermsg.Layout.Column = [ 1 2 ];
  configpowerhzslider = uislider( configprocgrid, ...
    'ValueChangedFcn', {@callback_procConfigSliderChanged} );
  guiConfigSlider( configpowerhzslider, ...
    { 'none', '50 Hz', '60 Hz' }, 3, '%s' );
  configpowerharmcheck = uicheckbox( configprocgrid, 'Text', 'harmonics', ...
    'ValueChangedFcn', {@callback_powerHarmChanged} );
  configpowerharmcheck.Value = want_notch_harmonics;

  configartifactmsg = uilabel( configprocgrid, 'Text', '', ...
    'FontWeight', 'bold' );
  configartifactmsg.Layout.Column = [ 1 2 ];
  configartifactslider = uislider( configprocgrid, ...
    'ValueChangedFcn', {@callback_procConfigSliderChanged} );
  guiConfigSlider( configartifactslider, ...
    { 'lenient', 'normal', 'aggressive' }, 2, '%s' );
  configartifactslider.Layout.Column = [ 1 2 ];

  ctl = uibutton( configprocgrid, 'Text', 'Done', ...
    'ButtonPushedFcn', {@callback_doneProcConfig} );
  ctl.Layout.Column = [ 1 2 ];

  % Update labels and store the configuration state based on these defaults.
  % FIXME - Overriding the tuning defaults!
  guiUpdateProcessingConfig();

  configprocgrid.Visible = 'off';


  %
  % "Processing" control panel.

  global processgrid;

  global processbanner;
  global processspikechan;
  global processburstchan;
  global processspikeplot;
  global processburstplot;

  global processspikeslider;
  global processburstslider;
  global processsortspikebutton;
  global processsortburstbutton;
  global processbackbutton;

  processgrid = uigridlayout( guifig, [ 6 2 ] );
  processgrid.RowHeight = { '2x', '1x', '9x', '1x', '2x', '1x' };

  tmpgrid = uigridlayout( processgrid, [ 1 2 ] );
  tmpgrid.Layout.Row = 1;
  tmpgrid.Layout.Column = [ 1 2 ];
  tmpgrid.ColumnWidth = { '3x', '1x' };
  % FIXME - uilabel is supposed to have 'WordWrap', but doesn't recognize it.
  processbanner = uilabel( tmpgrid, 'Text', 'Ready.' );
  processbackbutton = uibutton( tmpgrid, 'Text', 'Go Back', ...
    'Enable', 'off', 'ButtonPushedFcn', {@callback_procGoBack} );

  processspikechan = uilabel( processgrid, 'Text', '' );
  processburstchan = uilabel( processgrid, 'Text', '' );
  processspikeplot = uiaxes( processgrid );
  processburstplot = uiaxes( processgrid );
  guiMakeAxesNonInteractive( processspikeplot );
  guiMakeAxesNonInteractive( processburstplot );

  ctl = uilabel( processgrid, 'Text', 'Spike Threshold' );
  ctl = uilabel( processgrid, 'Text', 'Burst Threshold' );
  processspikeslider = uislider( processgrid, 'Enable', 'off', ...
    'ValueChangedFcn', {@callback_spikeThreshChanged} );
  guiConfigSlider( processspikeslider, ...
    tuningperc.spikerange, tuningperc.spikeselectidx, '%.3f' );
  processburstslider = uislider( processgrid, 'Enable', 'off', ...
    'ValueChangedFcn', {@callback_burstThreshChanged} );
  guiConfigSlider( processburstslider, ...
    tuningperc.burstrange, tuningperc.burstselectidx, '%.1f' );

  processsortspikebutton = uibutton( processgrid, ...
    'Text', 'Sort Spike Channels', ...
    'Enable', 'off', 'ButtonPushedFcn', {@callback_startSortSpikes} );
  processsortburstbutton = uibutton( processgrid, ...
    'Text', 'Sort Burst Channels', ...
    'Enable', 'off', 'ButtonPushedFcn', {@callback_startSortBursts} );

  processgrid.Visible = 'off';


  %
  % Spike channel sorting panel.

  % FIXME - NYI. (Spike channel sorting GUI.)

  global spikegrid;

  spikegrid = uigridlayout( guifig, [ 8 1 ] );

  ctl = uibutton( spikegrid, 'Text', 'Back', ...
    'ButtonPushedFcn', {@callback_backToProcess} );

  spikegrid.Visible = 'off';


  %
  % Burst channel sorting panel.

  global burstgrid;

  global burstbandlabel;
  global burstlowslider;
  global bursthighslider;
  global burstwidebutton;

  global burstplotrelative;
  global burstplotspect;
  global burstgridrelative;
  global burstgridspect;
  global burstplotonebutton;
  global burstplottypebutton;

  global burst_show_relative;

  global burstdatadirlabel;
  global burstplotdirlabel;
  global burstplotallbutton;
  global burstsaveallbutton;
  global burstresultlist;

  burstgrid = uigridlayout( guifig, [ 3 3 ] );
  burstgrid.ColumnWidth = { '2x', '1x', '3x' };
  burstgrid.RowHeight = { '4x', '4x', '1x' };

  % Band selection panel.

  tmpgrid = uigridlayout( burstgrid, [ 4 7 ] );
  tmpgrid.Layout.Row = 1;
  tmpgrid.Layout.Column = [ 1 2 ];
  tmpgrid.RowHeight = { '1x', '2x', '2x', '1x' };
  tmpgrid.ColumnWidth = { '1x', '1x', '1x', '1x', '1x', '1x', '1x' };

  burstbandlabel = uilabel( tmpgrid, 'Text', 'Band of interest:', ...
    'FontWeight', 'bold' );
  burstbandlabel.Layout.Column = [ 1 7 ];

  % NOTE - Deferring slider initialization.
  burstlowslider = uislider( tmpgrid, ...
    'ValueChangedFcn', {@callback_burstBandSliderChanged} );
  burstlowslider.Layout.Column = [ 1 7 ];
  bursthighslider = uislider( tmpgrid, ...
    'ValueChangedFcn', {@callback_burstBandSliderChanged} );
  bursthighslider.Layout.Column = [ 1 7 ];

  % NOTE - Wideband frequency limits get initialized later.
  burstwidebutton = uibutton( tmpgrid, 'Text', 'Wide', ...
    'ButtonPushedFcn', {@callback_burstBandSetFromButton} );
  ctl = uibutton( tmpgrid, 'Text', 'Theta', 'UserData', [ 4 8 ], ...
    'ButtonPushedFcn', {@callback_burstBandSetFromButton} );
  ctl = uibutton( tmpgrid, 'Text', 'Alpha', 'UserData', [ 8 12.5 ], ...
    'ButtonPushedFcn', {@callback_burstBandSetFromButton} );
  ctl = uibutton( tmpgrid, 'Text', 'Beta', 'UserData', [ 12.5 25 ], ...
    'ButtonPushedFcn', {@callback_burstBandSetFromButton} );
  ctl = uibutton( tmpgrid, 'Text', 'Ga (lo)', 'UserData', [ 25 50 ], ...
    'ButtonPushedFcn', {@callback_burstBandSetFromButton} );
  ctl = uibutton( tmpgrid, 'Text', 'Ga (md)', 'UserData', [ 50 100 ], ...
    'ButtonPushedFcn', {@callback_burstBandSetFromButton} );
  ctl = uibutton( tmpgrid, 'Text', 'Ga (hi)', 'UserData', [ 100 200 ], ...
    'ButtonPushedFcn', {@callback_burstBandSetFromButton} );

  % Initialize the band selection sliders.
  guiUpdateBandControls();

  % Plotting panes.
  % NOTE - The plotting panes are on top of each other, for adequate room.
  % They get their own grids, as that's the cleanest way to toggle visibility.

  burstgridrelative = uigridlayout(burstgrid, [ 1 1 ]);
  burstgridrelative.Layout.Column = 3;
  burstgridrelative.Layout.Row = [ 1 2 ];

  burstplotrelative = uiaxes(burstgridrelative);
  guiMakeAxesNonInteractive( burstplotrelative );
  burstgridrelative.Visible = 'off';

  burstgridspect = uigridlayout(burstgrid, [ 1 1 ]);
  burstgridspect.Layout.Column = 3;
  burstgridspect.Layout.Row = [ 1 2 ];

  burstplotspect = uiaxes(burstgridspect);
  guiMakeAxesNonInteractive( burstplotspect );
  burstgridspect.Visible = 'off';

  tmpgrid = uigridlayout( burstgrid, [ 1 3 ] );
  tmpgrid.Layout.Row = 3;
  tmpgrid.Layout.Column = 3;

  burstplotonebutton = uibutton( tmpgrid, 'Text', 'Plot This', ...
    'ButtonPushedFcn', {@callback_burstPlotOne} );
  burstplottypebutton = uibutton( tmpgrid, 'Text', 'Show Spectrum', ...
    'ButtonPushedFcn', {@callback_burstToggleRelative} );
  burst_show_relative = true;
  ctl = uicheckbox( tmpgrid, 'Text', 'slow and pretty', ...
    'ValueChangedFcn', {@callback_burstTogglePersist} );
  ctl.Layout.Column = 3;

  % Channel list.

  % This gets reinitialized momentarily.
  burstresultlist = uilistbox( burstgrid, ...
    'ValueChangedFcn', {@callback_burstListSelect} );
  burstresultlist.Layout.Row = [ 2 3 ];
  burstresultlist.Layout.Column = 2;

  % Panel for other controls.

  tmpgrid = uigridlayout( burstgrid, [ 6 2 ] );
  tmpgrid.Layout.Row = [ 2 3 ];
  tmpgrid.Layout.Column = 1;
  tmpgrid.RowHeight = { '2x', '2x', '1x', '2x', '1x', '2x' };
  tmpgrid.ColumnWidth = { '2x', '1x' };

  ctl = uibutton( tmpgrid, 'Text', 'Refresh List', ...
    'FontWeight', 'bold', 'ButtonPushedFcn', {@callback_burstRefreshList} );
  ctl = uibutton( tmpgrid, 'Text', 'Go Back', ...
    'ButtonPushedFcn', {@callback_backToProcess} );

  ctl = uilabel( tmpgrid, 'Text', 'Data directory:', ...
    'FontWeight', 'bold' );
  ctl = uibutton( tmpgrid, 'Text', 'Change', ...
    'ButtonPushedFcn', {@callback_burstChangeDataDir} );
  burstdatadirlabel = uilabel( tmpgrid, 'Text', 'No directory selected.' );
  burstdatadirlabel.Layout.Column = [ 1 2 ];

  ctl = uilabel( tmpgrid, 'Text', 'Plot directory:', ...
    'FontWeight', 'bold' );
  ctl = uibutton( tmpgrid, 'Text', 'Change', ...
    'ButtonPushedFcn', {@callback_burstChangePlotDir} );
  burstplotdirlabel = uilabel( tmpgrid, 'Text', 'No directory selected' );
  burstplotdirlabel.Layout.Column = [ 1 2 ];

  burstsaveallbutton = uibutton( tmpgrid, 'Text', 'Save All Data', ...
    'ButtonPushedFcn', {@callback_dataSaveAll} );
  burstplotallbutton = uibutton( tmpgrid, 'Text', 'Plot List', ...
    'ButtonPushedFcn', {@callback_burstPlotAll} );

  burstgrid.Visible = 'off';

  guiClearBurstResults();


  %
  % Ready to go.

  guiShowPanel('setup');

end


% This disables interactivity and menus in a set of axes.

function guiMakeAxesNonInteractive( target )

  disableDefaultInteractivity(target);
  target.Toolbar.Visible = 'off';

end


% This makes a modal pop-up progress message dialog.
% FIXME - We're making our own rather than using the uifigure version, so
% that it's in a separate window rather than inside the figure.
% The cancel callback is a cell array of event handlers; an empty array
% means no cancel button.
% NOTE - The caller is responsible for deleting the dialog.

function newdialog = guiMakeProgressDialog(message, cancel_callback)

  newdialog = msgbox(message, 'modal');

  % FIXME - Using knowledge of MessageBox internal structure.
  okbutton = newdialog.Children(1);

  if (0 < length(cancel_callback))
    % Make this a 'Cancel' button and set the callback.
    okbutton.String = 'Cancel';
    okbutton.Callback = cancel_callback;
  else
    % No callback. Leave this as "Ok" and disable.
    okbutton.Enable = 'off';
  end

end


% This sets a progress dialog's text.
% FIXME - We're making our own rather than using the uifigure version,
% per guiMakeProgressDialog().

function guiSetProgressDialogText(thisdialog, message)

  % FIXME - Using knowledge of MessageBox internal structure.
  thislabel = thisdialog.Children(2).Children(1);
  thislabel.String = { message };

  % Force a refresh.
  drawnow;

end


% This hides all panels, and then shows the specified panel.
% Target is a string ('setup', 'configproc', 'process').

function guiShowPanel(targetlabel)

  global guifig;
  global setupgrid;
  global configprocgrid;
  global processgrid;
  global spikegrid;
  global burstgrid;


  % First, turn everything off.

  setupgrid.Visible = 'off';
  configprocgrid.Visible = 'off';
  processgrid.Visible = 'off';
  spikegrid.Visible = 'off';
  burstgrid.Visible = 'off';

  guiToggleProcessButtons(false);


  % Next, look up the target label.
  % Default to the setup panel.

  target = setupgrid;
  sizelabel = 'small';

  if strcmp(targetlabel, 'setup')
    target = setupgrid;
  elseif strcmp(targetlabel, 'configproc')
    target = configprocgrid;
    sizelabel = 'tall';
  elseif strcmp(targetlabel, 'process')
    target = processgrid;
    sizelabel = 'large';
  elseif strcmp(targetlabel, 'spikes')
    target = spikegrid;
  elseif strcmp(targetlabel, 'bursts')
    target = burstgrid;
    sizelabel = 'large';
  else
    % Shouldn't happen, but report it if it does.
    disp(sprintf('### [guiShowPanel]  Invalid target "%s".', targetlabel));
  end


  % Figure out what window size we want and set it.

  guiwidth = 500;
  guiheight = 400;
  if strcmp('large', sizelabel)
    guiwidth = 900;
    guiheight = 500;
  elseif strcmp('tall', sizelabel)
    guiwidth = 500;
    guiheight = 600;
  end

  oldpos = guifig.Position;
  guifig.Position = [ oldpos(1) oldpos(2) guiwidth guiheight ];


  % Turn the desired control grid back on.

  target.Visible = 'on';


  % If we're showing the burst channel sorting panel, reset selected controls.

  if strcmp(targetlabel, 'bursts')
    % Frequency range may have changed. Reinitialize band selection.
    guiUpdateBandControls();

    % Our result list may no longer be valid; invalidate it and clear plots.
    guiClearBurstResults();

    % Update plot grid visibility, as both will be visible.
    guiShowBurstChannelPlot();
  end

end


% This sets the processing dialog's progress message.

function guiSetProcessingMessage(thismsg)

  global guifig;
  global processbanner;

  processbanner.Text = thismsg;

  % FIXME - Need to force a refresh during processing tasks.
  drawnow;

end


% This builds a grid of drop-down lists to select references in detected
% banks.

function guiMakeNewRefGrid()

  global refpanel;
  global refgrid;

  global probechans;
  global refchans;
  global folderlabel;

  global have_ref_grid;


  % Update tracking.

  if have_ref_grid
    refgrid.delete();
  end

  have_ref_grid = true;


  % Figure out what we have and how to present it.

  banklist = {};
  foldername = fieldnames(probechans);
  if length(foldername) > 0
    foldername = foldername{1};
    banklist = fieldnames(probechans.(foldername));
  end
  bankcount = length(banklist);
  rowcount = floor((bankcount + 3) / 4);


  % Render a set of drop-down lists.

  if 1 > bankcount

    % Special case: no banks.

    refgrid = uigridlayout( refpanel, [ 1 1 ] );
    ctl = uilabel( refgrid, 'Text', '(no banks found)' );

  else

    % Iterate, rendering 4 lists per row.
    % Note that we have a separate row for the reference names.

    refgrid = uigridlayout( refpanel, [ 2*rowcount 4 ] );

    for bidx = 1:bankcount

      bankid = banklist{bidx};
      bankchans = probechans.(foldername).(bankid).chanlist;
      chancount = length(bankchans);

      if 0 < chancount

        % Figure out which cell we're filling in.

        rowidx = floor((bidx - 1)/4);  % 0-based after this calc.
        colidx = bidx - 4*rowidx;  % Final 1-based value.
        rowidx = 1 + 2*rowidx;  % 1-based, odd value.

        % Make a label.

        ctl = uilabel( refgrid, 'Text', sprintf('Bank %s', bankid) );
        ctl.Layout.Row = rowidx;
        ctl.Layout.Column = colidx;

        % Build the list of possible reference channels for this bank.

        chanlabels = { 'none' };
        chanlist = { [] };

        for cidx = 1:chancount
          thischan = bankchans(cidx);
          chanlabels{1+cidx} = sprintf('%d', thischan);
          chanlist{1+cidx} = thischan;
        end

        % Create a drop-down list to select this bank's reference.
        % Store the bank ID in userdata.

        ctl = uidropdown( refgrid, 'UserData', bankid, ...
          'Items', chanlabels, 'ItemsData', chanlist );
        ctl.Layout.Row = rowidx + 1;
        ctl.Layout.Column = colidx;

        % Set the value, then set the value-changed callback.

        % Default selection is already 'none'.
        if isfield(refchans.(folderlabel), bankid)
          thisref = refchans.(folderlabel).(bankid).chanlist;
          if 0 < length(thisref)
            ctl.Value = thisref(1);
          end
        end

        ctl.ValueChangedFcn = { @callback_selectReference };

      end

    end

  end

end



% This configures a slider to step between several specified values.
% The values are stored in the "UserData" property.
% NOTE - The value list may be a cell array or number array.
% NOTE - For numeric values only, valpattern may be 'smartprec' to remove
% trailing zeroes from fractions.

function guiConfigSlider( sliderhandle, valuelist, selectidx, valpattern )

  valcount = length(valuelist);
  selectidx = min(selectidx, valcount);
  selectidx = max(selectidx, 1);


  sliderhandle.Limits = [ 1 valcount ];
  sliderhandle.Value = selectidx;

  sliderhandle.MajorTicks = 1:valcount;

  % Suppress minor ticks.
  sliderhandle.MinorTicks = sliderhandle.MajorTicks;

  labeltext = {};
  for lidx = 1:valcount
    if iscell(valuelist)
      labeltext{lidx} = sprintf(valpattern, valuelist{lidx});
    elseif strcmp('smartprec', valpattern)
      labeltext{lidx} = helper_formatSmartPrecision(valuelist(lidx));
    else
      labeltext{lidx} = sprintf(valpattern, valuelist(lidx));
    end
  end
  sliderhandle.MajorTickLabels = labeltext;

  % Store the selection values.
  sliderhandle.UserData = valuelist;

end


% This activates or deactivates process dialog buttons.
% These buttons should be enabled only after processing finishes.

function guiToggleProcessButtons(want_enabled)

  global processspikeslider;
  global processburstslider;
  global processsortspikebutton;
  global processsortburstbutton;
  global processbackbutton;

  if want_enabled
    processspikeslider.Enable = 'on';
    processburstslider.Enable = 'on';
    processsortspikebutton.Enable = 'on';
    processsortburstbutton.Enable = 'on';
    processbackbutton.Enable = 'on';
  else
    processspikeslider.Enable = 'off';
    processburstslider.Enable = 'off';
    processsortspikebutton.Enable = 'off';
    processsortburstbutton.Enable = 'off';
    processbackbutton.Enable = 'off';
  end

end


% This asks the user if they're sure they want to do something.

function resultbool = guiAreYouSure(dialogmsg, dialogtitle)

  % NOTE - We can't change the icon for this dialog.
  % FIXME - This doesn't disable input to the rest of the GUI, and can spawn
  % multiple times if its trigger is clicked multiple times!

  result = questdlg( dialogmsg, dialogtitle, 'Yes', 'Cancel', 'Cancel' );


  % NOTE - This makes a child window within the figure window.
%  result = uiconfirm( guifig, dialogmsg, dialogtitle, ...
%    'Icon', 'warning', 'Options', { 'Yes', 'Cancel' }, ...
%    'DefaultOption', 'Cancel', 'CancelOption', 'Cancel' );


  resultbool = false;
  if strcmp('Yes', result)
    resultbool = true;
  end

end


% This reads the state of processing configuration widgets, updates the
% tuning parameter structures to reflect them, and updates text labels.

function guiUpdateProcessingConfig()

  global tuningart;
  global tuningfilt;
  global tuningspect;

  global configlfpratemsg;
  global configlfphighmsg;
  global configlfplowmsg;
  global configpowermsg;
  global configartifactmsg;

  global configlfprateslider;
  global configlfphighslider;
  global configlfplowslider;
  global configpowerhzslider;
  global configpowerharmcheck;
  global configartifactslider;


  % LFP parameters.

  thisval = configlfprateslider.UserData(configlfprateslider.Value);
  configlfpratemsg.Text = sprintf('LFP sampling rate:  %d sps', thisval);
  tuningfilt.lfprate = thisval;

  thisval = configlfphighslider.UserData(configlfphighslider.Value);
  configlfphighmsg.Text = sprintf('LFP high corner:  %d Hz', thisval);
  tuningfilt.lfpcorner = thisval;

  thisval = configlfplowslider.UserData(configlfplowslider.Value);
  configlfplowmsg.Text = sprintf('LFP low corner:  %.1f Hz', thisval);
  tuningfilt.dcfreq = thisval;


  % Build spectrum tuning parameters that match the LFP filtering parameters.

  tuningspect.freqhigh = tuningfilt.lfpcorner;
  tuningspect.freqlow = tuningfilt.dcfreq;
  tuningspect.winsecs = 2 / tuningspect.freqlow;


  % Power filtering parameters.

  % Remember that this slider uses a cell array with string values.
  thisval = configpowerhzslider.UserData{configpowerhzslider.Value};

  tuningfilt.powerfreq = [];
  if strcmp('50 Hz', thisval)
    tuningfilt.powerfreq = 50;
  elseif strcmp('60 Hz', thisval)
    tuningfilt.powerfreq = 60;
  end

  if configpowerharmcheck.Value
    tuningfilt.powerfreq = ...
      [ tuningfilt.powerfreq tuningfilt.powerfreq tuningfilt.powerfreq ];
  end

  % Build label text.
  configpowermsg.Text = sprintf('Power filtering:  %s', thisval);
  if configpowerharmcheck.Value && (~strcmp('none', thisval))
    configpowermsg.Text = ...
      sprintf('Power filtering:  %s + harmonics', thisval);
  end


  % Artifact rejection parameters.

  % Remember that this slider uses a cell array with string values.
  thisval = configartifactslider.UserData{configartifactslider.Value};

  tuningart.ampthresh = 6;
  tuningart.diffthresh = 8;
  if strcmp('aggressive', thisval)
    tuningart.ampthresh = 4;
    tuningart.diffthresh = 6;
  elseif strcmp('lenient', thisval)
    tuningart.ampthresh = 8;
    tuningart.diffthresh = 10;
  end

  configartifactmsg.Text = sprintf('Artifact rejection:  %s', thisval);

end



% This updates the band channel sorting bane's band selection sliders to
% reflect a change in frequency limits.

function guiUpdateBandControls()

  global tuningfilt;
  global lfpfreqsteps;

  global burstlowslider;
  global bursthighslider;
  global burstwidebutton;

  global did_band_init;


  % Update the frequency scale.
  % This changes if the LFP band limits change.

  lfpfreqsteps = helper_getFreqSteps(tuningfilt.dcfreq, tuningfilt.lfpcorner);


  % Update the "wide band" button's data range.
  burstwidebutton.UserData = [ min(lfpfreqsteps) max(lfpfreqsteps) ];


  % Save the current slider frequencies, if we have them.
  % If not, set defaults.

  if did_band_init

    thislow = burstlowslider.UserData(burstlowslider.Value);
    thishigh = bursthighslider.UserData(bursthighslider.Value);

  else

    did_band_init = true;

    thislow = min(lfpfreqsteps);
    thishigh = max(lfpfreqsteps);

  end


  % Update the slider ranges.
  % Selected tick doesn't matter; it'll get updated momentarily.

  guiConfigSlider( burstlowslider, lfpfreqsteps, 1, 'smartprec' );
  guiConfigSlider( bursthighslider, lfpfreqsteps, 1, 'smartprec' );


  % Keep the old frequency values, or as close as we can get on the
  % new scale.

  guiUpdateBandSelection(thislow, thishigh);

end



% This updates the band channel sorting pane's band selection components
% to reflect a change in band state.
% If frequency arguments are NaN, they're read from the frequency sliders.

function guiUpdateBandSelection(newlow, newhigh)

  global lfpfreqsteps;

  global burstbandlabel;
  global burstlowslider;
  global bursthighslider;

  persistent oldlow;
  persistent oldhigh;


  if isnan(newlow)
    newlow = burstlowslider.UserData(burstlowslider.Value);
  end

  if isnan(newhigh)
    newhigh = bursthighslider.UserData(bursthighslider.Value);
  end


  % First, make sure the requested frequencies fall somewhere on the grid.
  % This finds the indices of the closest entries.

  errtmp = abs(lfpfreqsteps - newlow);
  idxlow = find(errtmp == min(errtmp));
  idxlow = idxlow(1);
  newlow = lfpfreqsteps(idxlow);

  errtmp = abs(lfpfreqsteps - newhigh);
  idxhigh = find(errtmp == min(errtmp));
  idxhigh = idxhigh(1);
  newhigh = lfpfreqsteps(idxhigh);


  % If we didn't have previous frequencies, use the current frequencies.

  if isempty(oldlow)
    oldlow = newlow;
  end

  if isempty(oldhigh)
    oldhigh = newhigh;
  end


  % If the sliders are in the wrong order, move whichever one was perturbed
  % the least from its previous position, in the log domain.
  % We're doing it this way instead of with indices because the frequency
  % steps may have changed since we last saved the values.

  difflow = abs(log(newlow / oldlow));
  diffhigh = abs(log(newhigh / oldhigh));

  if idxhigh <= idxlow
    if difflow < diffhigh
      idxlow = idxhigh - 1;
    else
      idxhigh = idxlow + 1;
    end
  end

  % Make sure we didn't nudge the indices out of range.

  if (idxlow < 1) || (idxhigh < 1)
    idxlow = 1;
    idxhigh = 2;
  end

  if (idxlow > length(lfpfreqsteps)) || (idxhigh > length(lfpfreqsteps))
    idxhigh = length(lfpfreqsteps);
    idxlow = idxhigh - 1;
  end

  % Store the nudged/quantized new frequencies.

  newlow = lfpfreqsteps(idxlow);
  newhigh = lfpfreqsteps(idxhigh);


  % Finally, store the canonical new frequencies and update the GUI.

  if (oldlow ~= newlow) || (oldhigh ~= newhigh)
    % Band selection has changed; clear the results list.
    guiClearBurstResults();
  end

  oldlow = newlow;
  oldhigh = newhigh;

  burstlowslider.Value = idxlow;
  bursthighslider.Value = idxhigh;

  burstbandlabel.Text = ...
    sprintf( 'Band of interest:  %.2f - %.2f', oldlow, oldhigh );

end


% This clears the plot axes in the bursts GUI.

function guiClearBurstPlotAxes();

  global burstplotrelative;
  global burstplotspect;
  global burstgridrelative;
  global burstgridspect;

  cla(burstplotrelative, 'reset');
  guiMakeAxesNonInteractive(burstplotrelative);
  burstgridrelative.Visible = 'off';

  cla(burstplotspect, 'reset');
  guiMakeAxesNonInteractive(burstplotspect);
  burstgridspect.Visible = 'off';

end


% This clears the results list and plots in the bursts GUI.

function guiClearBurstResults();

  global burstresultlist;

  guiClearBurstPlotAxes();

  burstresultlist.Value = {};
  burstresultlist.Items = {};
  burstresultlist.ItemsData = {};
  burstresultlist.Enable = 'off';

  guiReenableBurstControls();

end


% This disables or re-enables appropriate plotting and saving buttons.

function guiReenableBurstControls()

  global burstresultlist;
  global burstplotonebutton;
  global burstplottypebutton;
  global burstdatadirlabel;
  global burstplotdirlabel;
  global burstplotallbutton;
  global burstsaveallbutton;

  global burst_datadir;
  global burst_plotdir;


  have_plots = false;
  if (0 < length(burstresultlist.Value))
    have_plots = true;
  end

  have_results = false;
  if (0 < length(burstresultlist.Items))
    have_results = true;
  end

  have_datadir = ~strcmp('', burst_datadir);
  have_plotdir = ~strcmp('', burst_plotdir);

  if have_datadir
    burstdatadirlabel.Text = burst_datadir;
  else
    burstdatadirlabel.Text = 'No directory selected.';
  end

  if have_plotdir
    burstplotdirlabel.Text = burst_plotdir;
  else
    burstplotdirlabel.Text = 'No directory selected.';
  end


  burstplotonebutton.Enable = 'off';
  burstplottypebutton.Enable = 'off';
  burstplotallbutton.Enable = 'off';
  burstsaveallbutton.Enable = 'off';

  % FIXME - We can save even if we don't have results.
  if have_datadir
    burstsaveallbutton.Enable = 'on';
  end

  if have_plotdir && have_plots
    burstplotonebutton.Enable = 'on';
  end

  if have_plots
    burstplottypebutton.Enable = 'on';
  end

  if have_plotdir && have_results
    burstplotallbutton.Enable = 'on';
  end


end


% This shows the appropriate burst plot (excursion or spectrum), and
% updates the toggle button's text appropriately.

function guiShowBurstChannelPlot

  global burstgridrelative;
  global burstgridspect;
  global burstplottypebutton;

  global burst_show_relative;

  burstgridrelative.Visible = 'off';
  burstgridspect.Visible = 'off';

  if burst_show_relative
    burstplottypebutton.Text = 'Show Spectrum';
    burstgridrelative.Visible = 'on';
  else
    burstplottypebutton.Text = 'Show Excursions';
    burstgridspect.Visible = 'on';
  end

end


% This reads the current burst channel selection and plots it if it's valid.

function guiRefreshBurstPlots()

  global burstresultlist;
  global burstplotrelative;
  global burstplotspect;

  global tuningperc;

  global burst_want_persist;


  % Cell array containing zero or one event records.
  thisrec = burstresultlist.Value;

  if 0 < length(thisrec)

    % We only get a cell array for multi-select.
    % For single-select, this is already a bare record.

    guiClearBurstPlotAxes();

    nlPlot_axesPlotExcursions( burstplotrelative, ...
      thisrec.result.spectfreqs, thisrec.result.spectmedian, ...
      thisrec.result.spectiqr, thisrec.result.spectskew, ...
      tuningperc.burstrange, true, '' );

    if burst_want_persist
      nlPlot_axesPlotPersist( burstplotspect, thisrec.result.persistvals, ...
        thisrec.result.persistfreqs, thisrec.result.persistpowers, ...
        true, '' );
    else
      nlPlot_axesPlotExcursions( burstplotspect, ...
        thisrec.result.spectfreqs, thisrec.result.spectmedian, ...
        thisrec.result.spectiqr, thisrec.result.spectskew, ...
        tuningperc.burstrange, false, '' );
    end

    guiShowBurstChannelPlot();

  end

end


%
%
% GUI callback functions.


%
% Setup window callbacks.


function callback_selectDir(source, eventdata)

  global setupdir;
  global setupprocbutton;

  global indir;
  global folderlabel;
  global metadata;
  global probechans;
  global refchansdefault;
  global chanfilter;

  global have_metadata;
  global have_bankrefs;

  global burst_datadir;
  global burst_plotdir;


  have_metadata = false;
  have_bankrefs = false;

  newdir = uigetdir();

  % See if this folder contains anything we can understand.
  [is_ok metadata] = nlIO_readFolderMetadata( struct(), ...
    folderlabel, newdir, 'auto' );
  detchans = struct();

  if ~is_ok
    ctl = ...
      warndlg('No ephys data found in directory.', 'No data found.', 'modal' );
  else
    detchans = nlIO_getChanListFromMetadata(metadata);

    % FIXME - Hard-coded filtering!
    detchans = nlIO_filterChanList(detchans, chanfilter);

    if isempty(fieldnames(detchans))
      ctl = ...
        warndlg('No channels found in directory.', 'No data found.', 'modal' );
    end
  end

  if ~isempty(fieldnames(detchans))

    have_metadata = true;

    indir = newdir;
    % NOTE - Already pruned the channel list in the previous step.
    probechans = detchans;
    refchans = refchansdefault;

    setupdir.Text = indir;
    setupprocbutton.Enable = 'on';
    guiMakeNewRefGrid();

    % Reset save directories for results.
    burst_datadir = '';
    burst_plotdir = '';

  end

end


function callback_editTrimStart(source, eventdata)

  global tuningart;

  tuningart.trimstart = source.Value;

end


function callback_editTrimEnd(source, eventdata)

  global tuningart;

  tuningart.trimend = source.Value;

end


function callback_selectReference(source, eventdata)

  global refchans;
  global bankrefs;
  global folderlabel;

  % Force a reference list rebuild the next time we need references.
  have_bankrefs = false;

  bankid = source.UserData;
  channum = source.Value;

  % FIXME - Assume bank id and channel number are valid.
  % They're checked against the probed banks/channels when building the list.
  refchans.(folderlabel).(bankid).chanlist = channum;

end


function callback_editProcConfig(source, eventdata)

  guiShowPanel('configproc');

end


function callback_startProcess(source, eventdata)

  guiShowPanel('process');

  helper_runProcessing();

end



%
% Pre-processing config window callbacks.


% This is called for the LFP rate, LFP high, LFP low, and power Hz sliders.

function callback_procConfigSliderChanged(source, eventdata)

  % Snap to integer values.
  thisidx = source.Value;
  thisidx = round(thisidx);
  source.Value = thisidx;

  % Update the processing configuration and GUI state.
  guiUpdateProcessingConfig();

end


function callback_powerHarmChanged(source, eventdata)

  % Update the processing configuration and GUI state.
  guiUpdateProcessingConfig();

end


function callback_doneProcConfig(source, eventdata)

  guiShowPanel('setup');

end



%
% Processing window callbacks.


function callback_spikeThreshChanged(source, eventdata)

  global tuningperc;

  thisidx = source.Value;

  % Snap to integer values.
  thisidx = round(thisidx);
  source.Value = thisidx;

  % FIXME - We're not actually using this.
  thisperc = source.UserData(thisidx);

  tuningperc.spikeselectidx = thisidx;

end


function callback_burstThreshChanged(source, eventdata)

  global tuningperc;

  thisidx = source.Value;

  % Snap to integer values.
  thisidx = round(thisidx);
  source.Value = thisidx;

  % FIXME - We're not actually using this.
  thisperc = source.UserData(thisidx);

  tuningperc.burstselectidx = thisidx;

end


function callback_procGoBack(source, eventdata)

  if guiAreYouSure('Processing will have to be redone. Really go back?', ...
    'Confirm Go Back')

    guiShowPanel('setup');

  end

end


function callback_startSortSpikes(source, eventdata)

  guiShowPanel('spikes');

end


function callback_startSortBursts(source, eventdata)

  guiShowPanel('bursts');

end


% Not strictly processing window, but common to the two child windows.

function callback_backToProcess(source, eventdata)

  guiShowPanel('process');
  guiToggleProcessButtons(true);

end



%
% Spike channel sorting window callbacks.

% FIXME - NYI. (Spike channel sorting GUI callbacks.)



%
% Burst channel sorting window callbacks.


function callback_burstBandSliderChanged(source, eventdata)

  % Snap to integer values.
  thisidx = source.Value;
  thisidx = round(thisidx);
  source.Value = thisidx;

  % Update the band selection GUI state.
  % This reads the new values from the slider positions.
  guiUpdateBandSelection(NaN, NaN);

end


function callback_burstBandSetFromButton(source, eventdata)

  newrange = source.UserData;
  guiUpdateBandSelection( min(newrange), max(newrange) );

end


function callback_burstPlotOne(source, eventdata)

  global burstresultlist;


  % Redraw and save the plots associated with the selected record.
  % We're guaranteed to have a selected record, but check anyways.

  thisrec = burstresultlist.Value;
  if (0 < length(thisrec))

    % Make a figure. Hard-code the size.
    tempfig = figure();
    tempfig.Position = [ tempfig.Position(1) tempfig.Position(2) 1024 768 ];

    % Pop up a dialog, as this might take a little while.
    savedlg = guiMakeProgressDialog('Saving...', {});

    % Wrap the plotting helper.
    helper_saveOnePlot(tempfig, thisrec);

    % Done.
    delete(tempfig);
    delete(savedlg);

  end

end


function callback_burstToggleRelative(source, eventdata)

  global burst_show_relative;

  burst_show_relative = ~burst_show_relative;

  guiShowBurstChannelPlot();

end


function callback_burstTogglePersist(source, eventdata)

  global burst_want_persist;

  burst_want_persist = false;
  if source.Value
    burst_want_persist = true;
  end

  % Refresh the plots if we're plotting a record.
  guiRefreshBurstPlots();

end


function callback_burstRefreshList(source, eventdata)

  global processburstslider;
  global burstlowslider;
  global bursthighslider;
  global burstresultlist;

  global tuningperc;
  global lfpfreqsteps;

  global channelstats;


  burstpidx = processburstslider.Value;
  burstbandlow = burstlowslider.UserData(burstlowslider.Value);
  burstbandhigh = bursthighslider.UserData(bursthighslider.Value);

% FIXME - Diagnostics.
disp(sprintf( '-- Refresh burst list with percidx %d, band %.1f-%.1f Hz.', ...
burstpidx, burstbandlow, burstbandhigh ));

  burst_scorefunc = @(thisrec) helper_scoreBurstInBand( ...
    thisrec.spectskew{burstpidx}, lfpfreqsteps, ...
    [ burstbandlow burstbandhigh ] );

  % FIXME - Not limiting the number of channels returned.
  [ bestbursts typbest typmid typworst ] = ...
    nlChan_rankChannels(channelstats, inf, 0.1, burst_scorefunc);

  % This tolerates an empty result list.

  newlabels = {};
  newrecs = {};

  for ridx = 1:length(bestbursts)
    thisrec = bestbursts(ridx);
    thislabel = sprintf('%s - %03d', thisrec.bank, thisrec.chan);

    newlabels{1 + length(newlabels)} = thislabel;
    newrecs{1 + length(newrecs)} = thisrec;
  end

  burstresultlist.Value = {};
  burstresultlist.Items = newlabels;
  burstresultlist.ItemsData = newrecs;

  if (0 < length(newlabels))
    burstresultlist.Enable = 'on';
  end

  % Enable controls if appropriate.
  guiReenableBurstControls()

end


function callback_burstListSelect(source, eventdata)

  % Enable controls if appropriate.
  guiReenableBurstControls()

  % Refresh plots.
  guiRefreshBurstPlots();

end


function callback_burstChangeDataDir(source, eventdata)

  global burstdatadirlabel;
  global burst_datadir;

  burst_datadir = uigetdir();
  burstdatadirlabel.Text = burst_datadir;

  % Enable controls if appropriate.
  guiReenableBurstControls()

end


function callback_burstChangePlotDir(source, eventdata)

  global burstplotdirlabel;
  global burst_plotdir;

  burst_plotdir = uigetdir();
  burstplotdirlabel.Text = burst_plotdir;

  % Enable controls if appropriate.
  guiReenableBurstControls()

end


function callback_burstPlotAll(source, eventdata)

  global burstresultlist;

  if guiAreYouSure('Plotting all channels may take a while. Are you sure?', ...
    'Confirm Plot All')

    % Redraw and save plots for each element of the result list.

    reclist = burstresultlist.ItemsData;

    if (0 < length(reclist))

      % Make a figure. Hard-code the size.
      tempfig = figure();
      tempfig.Position = [ tempfig.Position(1) tempfig.Position(2) 1024 768 ];

      % Pop up a dialog, as this might take a little while.
      savedlg = guiMakeProgressDialog('Saving...', {});

      % Iterate.
      for ridx = 1:length(reclist)
        thisrec = reclist{ridx};
        guiSetProgressDialogText( savedlg, sprintf( 'Saving %s %03d...', ...
          thisrec.bank, thisrec.chan ) );
        helper_saveOnePlot(tempfig, thisrec);
      end

      % Done.
      delete(tempfig);
      delete(savedlg);

    end

  end
end



%
% Other callbacks.


function callback_dataSaveAll(source, eventdata)

  global tuningart;
  global tuningfilt;
  global tuningspect;
  global tuningperc;

  global indir;
  global refchans;
  global metadata;
  global chanfilter;

  global channelstats;

  global burst_datadir;

  global processburstslider;

  global burstlowslider;
  global bursthighslider;
  global burstresultlist;


  % FIXME - Saving spike data NYI.


  % Record user selections.

  channelconfig = struct( ...
    'folder', indir, 'references', refchans, 'metadata', metadata, ...
    'chanswanted', chanfilter, ...
    'tuningart', tuningart, 'tuningfilt', tuningfilt, ...
    'tuningspect', tuningspect, 'tuningperc', tuningperc, ...
    'burstperc', processburstslider.UserData(processburstslider.Value), ...
    'burstbandlow', burstlowslider.UserData(burstlowslider.Value), ...
    'burstbandhigh', bursthighslider.UserData(bursthighslider.Value) ...
    );

  % NOTE - Result lists might be empty. That's fine.
  sortedbursts = burstresultlist.ItemsData;


  % Pop up a dialog, as this might take a little while.

  savedlg = guiMakeProgressDialog('Saving...', {});


  %
  % Save everything in Matlab format.

  save( sprintf('%s/channelstats.mat', burst_datadir), ...
    'channelconfig', 'sortedbursts', 'channelstats' );


  %
  % Save selected items in CSV format.

  % FIXME - CSV data saving NYI.


  %
  % Finished saving.

  delete(savedlg);

end



%
%
% This is the end of the file.
