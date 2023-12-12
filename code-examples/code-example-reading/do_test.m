% NeuroLoop Project - Test program
% Written by Christopher Thomas.

%
% Library paths.

addPathsLoopUtil;



%
%
% Configuration.


%
% Behavior switches.


% Signal processing switches.

configflags = struct();

configflags.want_rereference = true;
configflags.want_filter = true;
configflags.want_artifactreject = true;
configflags.want_chanspikestats = true;
configflags.want_chanburststats = true;

% Plotting switches.

want_stats_chantool = false;
want_plots_chantool = true;


% Plot directory.

global plotdir;
plotdir = 'plots';


%
% Various tuning parameters.
% These may be overridden by dataset-specific configuration.

% Number of channels to load into memory concurrently.
memchans = 1;


%
% Dataset-specific configuration.

% This is expected to provide the following variables:
%
% - "folderlist" is a structure indexed by user-defined folder labels that
%   contains folder paths (i.e. a map from folder labels to path strings).
% - "chanlist" is a list of channels to process, per CHANLIST.txt. This
%   is optionally augmented with a "reflist" field specifying a reference
%   label to use with each channel.
% - "refdefs" is a structure indexed by user-defined reference labels that
%   contains channel lists (per CHANLIST.txt) defining signals to be used
%   to create references (averaged if multiple signals).
% - "tuningart" is an artifact-rejection tuning parameter structure, per
%   TUNING.txt.
% - "tuningfilt" is a filtering tuning parameter structure, per TUNING.txt.
% - "tuningperc" is a percentile statistics tuning parameter structure,
%   per TUNING.txt.
% - "tuningspect" is a time-frequency spectrogram tuning parameter structure,
%   per TUNING.txt.


% Set up defaults.

folderlist = struct();
chanlist = struct();
refdefs = struct();

tuningart = nlChan_getArtifactDefaults();
tuningfilt = nlChan_getFilterDefaults();
tuningspect = nlChan_getSpectrumDefaults();
tuningperc = nlChan_getPercentDefaults();


% Load dataset-specific changes.

do_config_reider;
%do_config_frey_tungsten;
%do_config_frey_silicon;



%
%
% Main Program


%
% Read metadata.

is_ok = true;
metadata = struct();
foldernames = fieldnames(folderlist);

disp('-- Reading metadata.');

for fidx = 1:length(foldernames)
  thisname = foldernames{fidx};
  [ folder_ok metadata ] = nlIO_readFolderMetadata( metadata, ...
    thisname, folderlist.(thisname), 'auto' );

  if ~folder_ok
    disp(sprintf( '... Failed to read from "%s"; bailing out.', ...
      folderlist.(thisname) ));
  end
  is_ok = is_ok && folder_ok;
end


%
% Build references.

% There are few enough of these that they can be stored in RAM without issue.

refseries = struct();

if is_ok && configflags.want_rereference
  disp('-- Building references.');

  % FIXME - Performance diagnostics.
  tic;

  % FIXME - Compute the reference values without any signal preprocessing.
  refpreprocfunc =  @(metadata, folderid, bankid, chanid, ...
    wavedata, timedata, wavenative, timenative) wavedata;

  refnames = fieldnames(refdefs);
  for ridx = 1:length(refnames)
    thisname = refnames{ridx};
    thisdef = refdefs.(thisname);
    refseries.(thisname) = nlProc_computeAverageSignal( ...
      metadata, thisdef, memchans, refpreprocfunc );
  end

  % FIXME - Performance diagnostics.
  disp(sprintf( '-- Reference compilation time:   %.1f s', toc ));
end


%
% Iterate channel by channel.

if is_ok

  disp('-- Processing signal data.');

  % FIXME - Performance diagnostics.
  global calctime;
  calctime = 0;

  % Reference selection is stored in chanlist (reflist field).
  % References themselves also need to be passed (refseries struct).

  % NOTE - Our helper function expects sample counts, not times, so use
  % "timenative".
  % NOTE - Our power scale expects uV rather than V, so multiply by 1e+6.
  sigprocfunc = @(metadata, folderid, bankid, chanid, ...
    wavedata, timedata, wavenative, timenative) ...
    helper_processChannel( metadata, folderid, bankid, chanid, ...
      wavedata * 1e+6, timenative, chanlist, refseries, configflags, ...
      tuningart, tuningfilt, tuningspect, tuningperc );

  resultlist = ...
    nlIO_iterateChannels( metadata, chanlist, memchans, sigprocfunc );

  % FIXME - Performance diagnostics.
  disp(sprintf( '-- Processing time:   %.1f s', calctime ));

end


%
% Generate statistics summaries and plots.


if is_ok
  % FIXME - Performance diagnostics.

  global renderspiketime;
  global renderpersisttime;
  global renderexcursiontime;

  renderspiketime = 0;
  renderpersisttime = 0;
  renderexcursiontime = 0;

  if want_stats_chantool
    disp('== Statistics:');
  end

  folderlist = fieldnames(resultlist);
  for fidx = 1:length(folderlist)
    folderid = folderlist{fidx};
    thisfolder = resultlist.(folderid);

    banklist = fieldnames(thisfolder);
    for bidx = 1:length(banklist)
      bankid = banklist{bidx};
      thisbank = thisfolder.(bankid);

      chanlist = thisbank.chanlist;
      for cidx = 1:length(chanlist)
        chanid = chanlist(cidx);
        thisresult = thisbank.resultlist{cidx};

        helper_plotChannel( thisresult, folderid, bankid, chanid, ...
          want_stats_chantool, want_plots_chantool, tuningperc );
      end
    end
  end

  if want_stats_chantool
    disp('== End of statistics.');
  end

  % FIXME - Performance diagnostics.
  if want_plots_chantool
    disp('-- Graphing time:');
    disp(sprintf( ...
      '%.1f s spike hist  %.1f s persist  %.1f s excursions', ...
      renderspiketime, renderpersisttime, renderexcursiontime ));
  end
end


disp('-- Finished.');


%
% Done.


%
%
% Private helper functions.


% This does per-channel signal processing.
% NOTE - For now, it's very much like what nlChan_processChannel() does.
% NOTE - We computed references without preprocessing (or truncating), so
% we need to do reference subtraction before those steps here too.

function resultval = helper_processChannel( ...
  metadata, folderid, bankid, chanid, ...
  wavedata, timedata, chanlist, refseries, configflags, ...
  tuningart, tuningfilt, tuningspect, tuningperc )

  % Reference selection is stored in chanlist (reflist field).
  % Reference waveforms themselves are in the refseries structure.


  % FIXME - Behavior switch. We can wrap nlChan_XX functions, or avoid them.
  want_nlchan = false;


  % Initialize the result to an empty structure.
  % Different processing operations add different fields to it.

  resultval = struct();


  % Sanity check; make sure we have this folder/bank/channel.
  % Copy metadata if we do.

  is_ok = false;
  if isfield(metadata.folders, folderid)
    foldermeta = metadata.folders.(folderid);
    if isfield(foldermeta.banks, bankid)
      bankmeta = foldermeta.banks.(bankid);
      if ismember(chanid, bankmeta.channels)
        is_ok = true;
      end
    end
  end


  % Process this channel.

  if is_ok

    % Banner.
    disp(sprintf( '... Processing %s-%s-%03d...', folderid, bankid, chanid ));


    % FIXME - Performance diagnostics.
    global calctime;
    tic;


    % Get this bank's sampling rate.

    samprate = bankmeta.samprate;


    % Get time trimming information.

    want_trim = false;
    if (tuningart.trimstart > 0) || (tuningart.trimend > 0)
      want_trim = true;
    end


    % Subtract the reference.
    % NOTE - We computed references without trimming or preprocessing, so
    % we need to subtract them before doing that here.

    if configflags.want_rereference
      % This tolerates missing references.
      % FIXME - Blithely assume that this channel is in the channel list.

      reflabel = '';
      if isfield(chanlist.(folderid).(bankid), 'reflist')
        bankchanlist = chanlist.(folderid).(bankid);
        % We _should_ have one match. We _may_ have zero or more matches.
        refidx = (bankchanlist.chanlist == chanid);
        reflabel = bankchanlist.reflist(refidx);
        if ~isempty(reflabel)
          reflabel = reflabel{1};
        end
      end

      if ~isempty(reflabel)
        if isfield(refseries, reflabel)
          wavedata = wavedata - refseries.(reflabel);
        end
      end
    end


    % Truncate the time and data series.

    if want_trim
      timedata = nlProc_trimEndpointsTime( ...
        timedata, samprate, tuningart.trimstart, tuningart.trimend );
      wavedata = nlProc_trimEndpointsTime( ...
        wavedata, samprate, tuningart.trimstart, tuningart.trimend );
    end

    % Squash the trim times after doing so, as otherwise the nlChan_XX
    % artifact rejection function will do it again.
    tuningart.trimstart = 0;
    tuningart.trimend = 0;


    % Perform artifact rejection.
    % We've already subtracted the reference, so don't pass a reference here.

    if configflags.want_artifactreject
      if want_nlchan
        % Use nlChan_applyArtifactReject().
        % NOTE - This does trimming as well, so squash trim times if using it.
        [ wavedata fracbad ] = nlChan_applyArtifactReject( ...
          wavedata, [], samprate, tuningart, false );
      else
        % Doing this directly (without nlChan_XX functions).

        wavedata = nlProc_removeArtifactsSigma( wavedata, ...
          tuningart.ampthresh, tuningart.diffthresh, ...
          tuningart.amphalo, tuningart.diffhalo, ...
          round(tuningart.timehalosecs * samprate), ...
          round(tuningart.timehalosecs * samprate), ...
          round(tuningart.smoothsecs * samprate), ...
          round(tuningart.dcsecs * samprate) );

        fracbad = sum(isnan(wavedata)) / length(wavedata);
        wavedata = nlProc_fillNaN(wavedata);
      end

      % FIXME - Diagnostics. Complain if this channel looks bad.
      if fracbad > 0.1
        disp(sprintf( '... NOTE - %d%% bad samples in %s-%s-%03d.', ...
          round(100*fracbad), folderid, bankid, chanid ));
      end
    end


    % Filter the signal to get LFP and spike waveforms.

    if configflags.want_filter
      if want_nlchan
        % Use nlChan_applyFiltering().
        [ lfpseries spikeseries ] = ...
          nlChan_applyFiltering( wavedata, samprate, tuningfilt );
      else
        % Doing this directly (without nlChan_XX functions).
        [ lfpseries spikeseries ] = ...
          nlProc_filterSignal( wavedata, samprate, ...
            tuningfilt.lfprate, tuningfilt.lfpcorner, ...
            tuningfilt.powerfreq, tuningfilt.dcfreq );
      end

      % Now that we have LFP and spike waveforms, compute channel stats.

      % Compute and save per-channel spike statistics.
      if configflags.want_chanspikestats
        [ spikemedian spikeiqr spikeskew spikepercentvals ] = ...
          nlProc_calcSkewPercentile(spikeseries, tuningperc.spikerange);

        spikebinedges = -20:0.5:20;
        [ spikebincounts spikebinedges ] = ...
          histcounts(spikeseries / spikeiqr, spikebinedges);

        resultval.spikemedian = spikemedian;
        resultval.spikeiqr = spikeiqr;
        resultval.spikeskew = spikeskew;
        resultval.spikepercentvals = spikepercentvals;

        resultval.spikebincounts = spikebincounts;
        resultval.spikebinedges = spikebinedges;
      end

      % Compute and save per-channel burst statistics.
      % This includes a persistence spectrum.
      if configflags.want_chanburststats
        lfprate = tuningfilt.lfprate;

        if want_nlchan
          [ spectfreqs spectmedian spectiqr spectskew ] = ...
            nlChan_applySpectSkewCalc( lfpseries, lfprate, ...
              tuningspect, tuningperc.burstrange );
        else
          % Doing this directly (without nlChan_XX functions).
          [ spectfreqs spectmedian spectiqr spectskew ] = ...
            nlProc_calcSpectrumSkew( lfpseries, lfprate, ...
              [ tuningspect.freqlow tuningspect.freqhigh ], ...
              tuningspect.freqsperdecade, ...
              tuningspect.winsecs, tuningspect.winsteps, ...
              tuningperc.burstrange );
        end

        % There is no nlChan_XX wrapper for this.
        [ persistvals persistfreqs persistpowers ] = ...
          pspectrum( lfpseries, lfprate, 'persistence', ...
            'Leakage', 0.75, ...
            'FrequencyLimits', [tuningspect.freqlow tuningspect.freqhigh], ...
            'TimeResolution', tuningspect.winsecs );

        resultval.spectfreqs = spectfreqs;
        resultval.spectmedian = spectmedian;
        resultval.spectiqr = spectiqr;
        resultval.spectskew = spectskew;

        resultval.persistvals = persistvals;
        resultval.persistfreqs = persistfreqs;
        resultval.persistpowers = persistpowers;
      end
    end


    % FIXME - Performance diagnostics.
    calctime = calctime + toc;
  end

end



% This reports statistics and generates plots for one channel's data.

function helper_plotChannel( thisdata, thisfolder, thisbank, thischan, ...
  want_stats, want_plots, tuningperc )

  % FIXME - Plot directory.

  global plotdir;

  % FIXME - Performance diagnostics.

  global renderspiketime;
  global renderpersisttime;
  global renderexcursiontime;


  %
  % Statistics reporting.
  % NOTE - Some or all of these may be missing.

  if want_stats

    disp(sprintf( '-- Statistics for %s-%s-%03d...', ...
      thisfolder, thisbank, thischan ));

    spikerange = tuningperc.spikerange;
    burstrange = tuningperc.burstrange;

    if isfield(thisdata, 'spikeskew')
      spikeskew = thisdata.spikeskew;

      for pidx = 1:length(spikerange)
        disp(sprintf( 'Spike skew %.3f %%:   %.2f', ...
          spikerange(pidx), spikeskew(pidx) ));
      end
    end

    if isfield(thisdata, 'spectskew')
      spectskew = thisdata.spectskew;

      for pidx = 1:length(tuningperc.burstrange)
        thisspectskew = spectskew{pidx};
        disp(sprintf( 'Burst skew %.2f %%:   %.2f - %.2f', ...
          burstrange(pidx), min(thisspectskew), max(thisspectskew) ));
      end
    end

  end


  %
  % Statistics plots and time/frequency plots.
  % NOTE - Some or all of these may be missing.

  if want_plots

    disp(sprintf( ...
      '-- Plotting histograms and spectrograms for %s-%s-%03d...', ...
      thisfolder, thisbank, thischan ));


    thisfig = figure();


    casetitle = sprintf('Channel %s %s %03d', thisfolder, thisbank, thischan);
    caselabel = sprintf('%s-%s-%03d', thisfolder, thisbank, thischan);


    % FIXME - We no longer have access to the raw waveform here.
%    helper_plotSignal( samprate, lfprate, ...
%      dataseries, interpseries, lfpseries, spikeseries, ...
%      casetitle, caselabel, sprintf('%s/input', plotdir) );


    if isfield(thisdata, 'spikeiqr')
      tic;

      spikeiqr = thisdata.spikeiqr;

      % The bin edges are multiples of the IQR. Normalize the percentage
      % values to match this.

      nlPlot_plotSpikeHist( thisfig, ...
        sprintf('%s/spikes-%s-hist.png', plotdir, caselabel), ...
        thisdata.spikebincounts, thisdata.spikebinedges, ...
        thisdata.spikepercentvals / spikeiqr, tuningperc.spikerange, ...
        sprintf('%s - HPF Amplitude', casetitle) );

      renderspiketime = renderspiketime + toc;
    end


    if isfield(thisdata, 'persistvals')
      tic;

      want_log = true;

      nlPlot_plotPersist( thisfig, ...
        sprintf('%s/spect-persist-%s.png', plotdir, caselabel), ...
        thisdata.persistvals, thisdata.persistfreqs, thisdata.persistpowers, ...
        want_log, sprintf('%s - Persistence Spectrum', casetitle) );

      renderpersisttime = renderpersisttime + toc;
    end


    if isfield(thisdata, 'spectskew')
      tic;

      % Make one call to plot relative and one to plot absolute.

      nlPlot_plotExcursions( thisfig, ...
        sprintf('%s/spect-burst-rel-%s.png', plotdir, caselabel), ...
        thisdata.spectfreqs, thisdata.spectmedian, ...
        thisdata.spectiqr, thisdata.spectskew, ...
        tuningperc.burstrange, ...
        true, sprintf('%s - Power Excursions (relative)', casetitle) );

      nlPlot_plotExcursions( thisfig, ...
        sprintf('%s/spect-burst-abs-%s.png', plotdir, caselabel), ...
        thisdata.spectfreqs, thisdata.spectmedian, ...
        thisdata.spectiqr, thisdata.spectskew, ...
        tuningperc.burstrange, ...
        false, sprintf('%s - Power Excursions (absolute)', casetitle) );

      renderexcursiontime = renderexcursiontime + toc;
    end


    close(thisfig);

  end


  %
  % Done.

end



% This plots an extended signal.
% FIXME - This is quick and dirty!

function helper_plotSignal( samprate, lfprate, ...
  rawseries, cleanseries, lfpseries, spikeseries, ...
  casetitle, caselabel, obase )

  colblu = [ 0.0 0.4 0.7 ];
  colbrn = [ 0.8 0.4 0.1 ];
  colgrn = [ 0.5 0.7 0.2 ];
  colmag = [ 0.5 0.2 0.5 ];
  colcyn = [ 0.3 0.7 0.9 ];

  zoomlut = struct( 'limits', { [], [ 500 520 ] }, ...
    'title', { 'Full', 'Detail' }, 'label', { 'all', 'det' } );

  thisfig = figure();

  for zidx = 1:length(zoomlut)

    thisrange = zoomlut(zidx).limits;
    ztitle = zoomlut(zidx).title;
    zlabel = zoomlut(zidx).label;

    clf('reset');


    subplot(4,1,1);

    timeseries = 1:length(rawseries);
    timeseries = (timeseries - 1) / samprate;

    hold on;
    plot( timeseries, rawseries, 'Color', colmag );
    plot( timeseries, cleanseries, 'Color', colcyn );
    hold off;

    title(sprintf('%s - Raw - %s', casetitle, ztitle));
    xlabel('Time (s)');
    ylabel('Amplitude (a.u.)');

    if (2 == length(thisrange))
      xlim(thisrange);
    else
      xlim auto;
    end


    subplot(4,1,2);

    timeseries = 1:length(cleanseries);
    timeseries = (timeseries - 1) / samprate;

    plot( timeseries, cleanseries, 'Color', colblu );

    title(sprintf('%s - Clean - %s', casetitle, ztitle));
    xlabel('Time (s)');
    ylabel('Amplitude (a.u.)');

    if (2 == length(thisrange))
      xlim(thisrange);
    else
      xlim auto;
    end


    subplot(4,1,3);

    timeseries = 1:length(lfpseries);
    timeseries = (timeseries - 1) / lfprate;

    plot( timeseries, lfpseries, 'Color', colbrn );

    title(sprintf('%s - LFP - %s', casetitle, ztitle));
    xlabel('Time (s)');
    ylabel('Amplitude (a.u.)');

    if (2 == length(thisrange))
      xlim(thisrange);
    else
      xlim auto;
    end


    subplot(4,1,4);

    timeseries = 1:length(spikeseries);
    timeseries = (timeseries - 1) / samprate;

    plot( timeseries, spikeseries, 'Color', colgrn );

    title(sprintf('%s - Spikes - %s', casetitle, ztitle));
    xlabel('Time (s)');
    ylabel('Amplitude (a.u.)');

    if (2 == length(thisrange))
      xlim(thisrange);
    else
      xlim auto;
    end


    saveas( thisfig, sprintf('%s-%s-%s.png', obase, caselabel, zlabel) );

  end

  close(thisfig);


  %
  % Done.

end


%
%
% This is the end of the file.
