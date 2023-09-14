function [ newwave fitlist reportstr ] = nlArt_guessMultipleExpDecays( ...
  timeseries, waveseries, fitconfig, plotconfig, ...
  tattle_verbosity, report_verbosity, reportlabel )

% function [ newwave fitlist reportstr ] = nlArt_guessMultipleExpDecays( ...
%   timeseries, waveseries, fitconfig, plotconfig, ...
%   tattle_verbosity, report_verbosity, reportlabel )
%
% This uses black magic to guess where exponential curve fits should be
% performed to remove artifacts. It's more robust than fitting to fixed
% time spans, but requires a lot of hand-tuned configuration parameters.
%
% Artifacts are assumed to be confined to a user-specified span. Fits are
% subtracted only within that span, for generating the corrected wave.
%
% Plots of curve fit attempts are optionally generated. These are useful
% when hand-tuning the configuration parameters.
%
% "timeseries" is a vector containing sample times.
% "waveseries" is a vector containing sample values to be curve-fit.
% "fitconfig" is a configuration structure, per EXPGUESSCONFIG.txt.
% "plotconfig" is a structure with the fields described in EXPGUESSPLOT.txt,
%   or struct([]) to suppress plotting and reports.
% "tattle_verbosity" is 'quiet', 'terse', 'normal', or 'verbose'. This
%   controls how many debugging/progress messages are sent to the console.
% "report_verbosity" is 'quiet', 'terse', 'normal', or 'verbose'. This
%   controls how many debugging/progress messages are appended to the
%   report string.
% "reportlabel" is an identifier to prepend to curve fit report messages.
%
% "newwave" is a copy of "waveseries" with the curve fits subtracted.
% "fitlist" is a cell array holding curve fit parameters for successive
%   curve fits, per ARTFITPARAMS.txt.
% "reportstr" is a character vector containing debugging/progress messages
%   selected by "report_verbosity".


newwave = waveseries;
fitlist = {};
tattlestr = '';
reportstr = '';


% Get tattle and plot metadata.

want_plots = ~isempty(plotconfig);

tattle_all = strcmp(tattle_verbosity, 'verbose');
tattle_some = tattle_all || strcmp(tattle_verbosity, 'normal');
tattle_few = tattle_some || strcmp(tattle_verbosity, 'terse');

write_all = strcmp(report_verbosity, 'verbose');
write_some = write_all || strcmp(report_verbosity, 'normal');
write_few = write_some || strcmp(report_verbosity, 'terse');



% If we've been asked to pre-filter the input, do so.
% Make a second-order Butterworth filter and run it backwards and forwards.

samprate = 1 / mean(diff(timeseries));

if ~isnan(fitconfig.lowpass_corner)

  % If we want to squash an artifact region before filtering, do so.
  if ~isempty(fitconfig.lowpass_squash_ms)
    squashmin = min(fitconfig.lowpass_squash_ms) / 1000;
    squashmax = max(fitconfig.lowpass_squash_ms) / 1000;
    thismask = (timeseries > squashmin) & (timeseries < squashmax);
    waveseries(thismask) = NaN;
  end

  % Pave over NaNs before filtering.
  nanmask = isnan(waveseries);
  waveseries = nlProc_fillNaN(waveseries);

  % This wants f_corner / f_nyquist as input.
  [filtb, filta] = ...
    butter(2, fitconfig.lowpass_corner / (0.5 * samprate),'low');
  waveseries = filtfilt(filtb, filta, waveseries);

  % Restore NaNs.
  waveseries(nanmask) = NaN;

  [ tattlestr reportstr ] = helper_addMessage( ...
    tattlestr, reportstr, tattle_some, write_some, ...
    sprintf( '(%s)  Low-pass filtering with %d Hz cutoff.', ...
      reportlabel, round(fitconfig.lowpass_corner) ));
end



% Get relevant timespans.
% Clamping to the user-specified time range.

firsttime = min(timeseries);
lasttime = max(timeseries);

fullfirst = min(fitconfig.full_time_range_ms) / 1000;
fulllast = max(fitconfig.full_time_range_ms) / 1000;

firsttime = max(firsttime, fullfirst);
lasttime = min(lasttime, fulllast);

scratch = (lasttime - firsttime) * fitconfig.post_level_span + firsttime;
postfirst = min(scratch);
postlast = max(scratch);

minfittime = firsttime + ( fitconfig.min_fit_offset_ms / 1000 );

fitlastmin = firsttime + ( fitconfig.min_detect_ms / 1000 );
fitfirstmin = firsttime + ( fitconfig.min_first_detect_ms / 1000 );


% Iteratively produce fit estimates.

fitcount = 0;
done = false;
residue = waveseries;

searchlimit = postlast;

while ~done

  % Figure out what our "we have a clear artifact" range is in the residue.
  % We're clamping the "first" value to t = 0, since if there was a stepwise
  % discontinuity at stimulation the previous samples may look like outliers.
  % We're clamping the "last" value to the "search limit" time, so that we
  % can perform successive curve fits without re-matching the same region.

  [ artfirst artlast threshlow threshhigh dcafter ] = ...
    nlProc_getOutlierTimeRange( timeseries, waveseries, ...
      [ 0 searchlimit ], [ postfirst postlast ], ...
      25, 75, fitconfig.detect_threshold, fitconfig.detect_threshold );


  % Check for ending conditions from detection.
  % A "first" value substantially _later_ than t = 0 means we're in a sham
  % case and set the threshold too low.
  % We only actually use the "last" value.

  if isnan(artlast)
    % Nothing detected.
    done = true;
  elseif artlast < minfittime
    done = true;
  elseif artlast < fitlastmin
    done = true;
  elseif (fitcount < 1) && (artlast < fitfirstmin)
    done = true;
  elseif artfirst > (fitconfig.detect_max_start * abs(artlast))
    % Late oscillation or double triggering, I think.
    done = true;
  end


  % Report the initial detected artifact range.

  if isnan(artlast)
    [ tattlestr reportstr ] = helper_addMessage( ...
      tattlestr, reportstr, tattle_all, write_all, ...
      [ '(' reportlabel ')  No artifact detected.' ] );
  elseif done
    [ tattlestr reportstr ] = helper_addMessage( ...
      tattlestr, reportstr, tattle_all, write_all, ...
      sprintf( '(%s)  (spurious) %d ms to %d ms.', ...
        reportlabel, round(artfirst * 1000), round(artlast * 1000) ));
  else
    [ tattlestr reportstr ] = helper_addMessage( ...
      tattlestr, reportstr, tattle_some, write_some, ...
      sprintf( '(%s)  (%d) detected %d ms to %d ms.', ...
        reportlabel, fitcount + 1, ...
        round(artfirst * 1000), round(artlast * 1000) ));
  end


  if ~done

    % Record the detection time.

    artdetect = artlast;

    % Fallback: Multiply the detection time to get the first and last time.

    artlast = artdetect * max(fitconfig.fit_range);
    artlast = min(artlast, lasttime);

    artfirst = artdetect * min(fitconfig.fit_range);
    artfirst = max(artfirst, minfittime);


    % Report the curve fit first/last range.

    [ tattlestr reportstr ] = helper_addMessage( ...
      tattlestr, reportstr, tattle_some, write_some, ...
      sprintf( '(%s)  (%d) fitting %d ms to %d ms.', ...
        reportlabel, fitcount + 1, ...
        round(artfirst * 1000), round(artlast * 1000) ));


    % Do the curve fit.

    fitmethod = fitconfig.fitmethod;

    thismask = (timeseries >= artfirst) & (timeseries <= artlast);
    timefit = timeseries(thismask);
    wavefit = waveseries(thismask);

    dcfit = dcafter;

    % Nudge the DC offset if we have an overshoot, as that gives curve fits
    % that misbehave.
    if true
      startval = wavefit(1);
      maxval = max(wavefit);
      minval = min(wavefit);

      if startval < dcfit
        % If we have an overshoot, set the DC value to that.
        dcfit = max(maxval, dcfit);
      else
        % If we have an undershoot, set the DC value to that.
        dcfit = min(minval, dcfit);
      end
    end


    % NOTE - Auto-fitting instead of using "dcfit" tends to give a better
    % DC level estimate but a worse curve fit.
    thisfit = nlArt_fitExpDecay( timefit, wavefit, dcfit, fitmethod );


    % Sanity-check the curve fit before continuing.

    done = true;

    % If the type isn't "exp", we weren't able to fit at all.
    if strcmp(thisfit.fittype, 'exp')
      % Straight-up reject rising ramp fits (positive tau).
      % This shouldn't happen with the way we pick regions, but test anyways.
      if isfinite(thisfit.tau) && (thisfit.tau < 0)
        % FIXME - We want to do a scale factor test, but figuring out a
        % plausible coefficient range is error-prone.

        thisscale = min( abs(threshlow), abs(threshhigh) );
        thisscale = thisscale * 1e-2;
        thisscale = thisscale / exp(artfirst * thisfit.tau);

        if isfinite(thisfit.coeff) && (abs(thisfit.coeff) >= thisscale)

          % This seems to be a valid curve fit.

          done = false;
          fitcount = fitcount + 1;
          fitlist{fitcount} = thisfit;

        else
          % Debug tattle.
          [ tattlestr reportstr ] = helper_addMessage( ...
            tattlestr, reportstr, tattle_few, write_all, ...
            [ '### [nlArt_guessMultipleExpDecays]  ' ...
              'Rejecting fit with bad scale.' ]);
        end
      else
        % Debug tattle.
        [ tattlestr reportstr ] = helper_addMessage( ...
          tattlestr, reportstr, tattle_few, write_all, ...
          [ '### [nlArt_guessMultipleExpDecays]  ' ...
            'Rejecting fit with bad tau.' ]);
      end
    end


    % If we had a valid curve fit, plot it.
    % If we didn't have a valid curve fit, still plot the search parameters.

    if want_plots

      attemptnumber = fitcount;

      if done
        % Squash invalid/failed fits.
        thisfit = struct([]);

        % Increment the attempt number, since fitcount wasn't incremented.
        attemptnumber = attemptnumber + 1;
      end

      helper_plotCurveFitAttempt( timeseries, waveseries, plotconfig, ...
        [ artfirst artdetect artlast ], [ postfirst postlast ], ...
        [ threshlow dcafter threshhigh ], thisfit, attemptnumber );

    end


    % If we had a valid curve fit, subtract it.
    if ~done
      thismask = (timeseries > 0);
      thisrecon = nlArt_reconFit( timeseries(thismask), thisfit );
      waveseries(thismask) = waveseries(thismask) - thisrecon;
    end


    % Check for hitting our max number of curve fits.
    if fitcount >= fitconfig.max_curves
      done = true;
    end



    % Set up the DC level region and search region for the next detection.

    % Walk the search limit forward on each iteration, to avoid re-fitting.
    searchlimit = (artdetect - firsttime) * fitconfig.next_mult;
    searchlimit = searchlimit + firsttime;

    % Figure out where we want to measure the DC level.
    if false
      % This estimates DC at the detection point, where the curve fit should
      % be most accurate.
      scratch = (artdetect - firsttime) * fitconfig.post_level_span;
    elseif false
      % This estimates DC at the tail of the area we just curve fit.
      % This is sometimes better (with a good fit) and sometimes worse
      % (if a poor fit caused the DC level to wander).
      scratch = (artlast - firsttime) * fitconfig.post_level_span;
    elseif true
      % This estimates DC from a user-specified multiple of the detect time.
      scratch = (artdetect - firsttime) * fitconfig.dc_from_detect_span;
    else
      % This keeps the original DC estimation region, which will fail if the
      % curve fit causes the local level to wander.
      scratch = [ postfirst postlast ] - firsttime;
    end

    scratch = scratch + firsttime;
    postfirst = min(scratch);
    postlast = max(scratch);

  end

end

if fitcount > 0
  [ tattlestr reportstr ] = helper_addMessage( ...
    tattlestr, reportstr, tattle_few, write_few, ...
    sprintf( '(%s)  Fit %d exponentials.', reportlabel, fitcount ));
else
  [ tattlestr reportstr ] = helper_addMessage( ...
    tattlestr, reportstr, tattle_some, write_some, ...
    sprintf( '(%s)  No exponentials found.', reportlabel ));
end


% Store the modified wave.
newwave = waveseries;


% Emit the console reports, if we have any.
if ~isempty(tattlestr)
  disp(tattlestr);
end


% Done.
end



%
% Helper Functions


% This appends a message to the tattle string and the report string, if
% the corresponding flags are true.

function [ newtattle newreport ] = helper_addMessage( ...
  oldtattle, oldreport, want_tattle, want_report, thismsg )

  newtattle = oldtattle;
  newreport = oldreport;

  eol = sprintf('\n');

  if want_tattle
    if isempty(newtattle)
      newtattle = thismsg;
    else
      newtattle = [ newtattle eol thismsg ];
    end
  end

  if want_report
    newreport = [ newreport thismsg eol ];
  end

end



% This plots an individual waveform with curve fit setup parameters and
% a curve fit (if provided).
%
% function helper_plotCurveFitAttempt( timeseries, waveseries, plotconfig, ...
%   detecttimes, dctimes, detectlevels, fitparams, fitnumber )
%
% "timeseries" is a vector with sample timestamps for the input wave.
% "waveseries" is a vector with sample values for the input wave.
% "plotconfig" is a structure with the following fields (per above):
%   "plot_sizes_ms", "plot_labels", "fileprefix", "titleprefix"
% "detecttimes" [ first middle last ] is a vector with timestamps for the
%   range to be curve fit (first/last) and the time at which the artifact
%   crossed the detection threshold (middle).
% "dctimes" [ first last ] is a vector describing the time range in which
%   the DC level was measured.
% "detectlevels" [ low middle high ] is a vector with signal level thresholds
%   for artifact detection (low/high) and for the DC level (middle).
% "fitparams" is a curve fit description structure per ARTFITPARAMS.txt.
%   If no fit is to be plotted, this is struct([]).
% "fitnumber" is the attempt number of the curve fit being plotted.
%
% No return value.

function helper_plotCurveFitAttempt( timeseries, waveseries, plotconfig, ...
  detecttimes, dctimes, detectlevels, fitparams, fitnumber )

  % Get config data.

  zoomsizes_ms = plotconfig.fit_plot_sizes_ms;
  zoomlabels = plotconfig.fit_plot_labels;

  filebase = plotconfig.fileprefix;
  titlebase = plotconfig.titleprefix;

  time_squash_range = plotconfig.time_squash_ms / 1000;
  if ~isempty(time_squash_range)
    thismask = (timeseries >= min(time_squash_range)) ...
      & (timeseries <= max(time_squash_range));
    waveseries(thismask) = NaN;
  end

  % This tolerates NaN samples without trouble.
  maxtime = -inf;
  mintime = inf;
  for zidx = 1:length(zoomsizes_ms)
    thisrange = zoomsizes_ms{zidx};
    maxtime = max(maxtime, max(thisrange));
    mintime = min(mintime, min(thisrange));
  end

  maxwave = max(waveseries);
  minwave = min(waveseries);
  halosize = 0.1 * (maxwave - minwave);
  maxwave = maxwave + halosize;
  minwave = minwave - halosize;


  % Plot the figure once.

  thisfig = figure();
  clf('reset');

  cols = nlPlot_getColorPalette();

  hold on;

  plot( timeseries * 1000, waveseries, ...
    'Color', cols.yel, 'HandleVisibility', 'off' );

  for tidx = 1:length(detecttimes)
    thistime = detecttimes(tidx) * 1000;
    plot( [ thistime thistime ], [ minwave maxwave ], ...
      'Color', cols.cyn, 'HandleVisibility', 'off' );
  end

  for tidx = 1:length(dctimes)
    thistime = dctimes(tidx) * 1000;
    plot( [ thistime thistime ], [ minwave maxwave ], ...
      'Color', cols.mag, 'HandleVisibility', 'off' );
  end

  for lidx = 1:length(detectlevels)
    thislevel = detectlevels(lidx);
    plot( [ mintime maxtime ] * 1000, [ thislevel thislevel ], ...
      'Color', cols.red, 'HandleVisibility', 'off' );
  end

  if ~isempty(fitparams)
    thismask = (timeseries > 0);
    recontime = timeseries(thismask);
    reconwave = nlArt_reconFit(recontime, fitparams);

    plot( recontime * 1000, reconwave, ...
      'Color', cols.blu, 'HandleVisibility', 'off' );
  end

  hold off;

  xlabel('Time (ms)');
  ylabel('Amplitude (a.u.)');

  % Clamp the Y range so that the curve fit exponential doesn't dominate it.
  ylim([ minwave maxwave ]);


  % Render and save the figure multiple times, now that we've plotted it.

  for zidx = 1:length(zoomsizes_ms)
    thisrange = zoomsizes_ms{zidx};
    thiszoom = zoomlabels{zidx};

    xlim(thisrange);
    title( sprintf('%s - Fit %d - %s', titlebase, fitnumber, thiszoom) );

    saveas( thisfig, ...
      sprintf('%s-fit%d-%s.png', filebase, fitnumber, thiszoom) );
  end


  % Get rid of the figure.
  close(thisfig);

end



%
% This is the end of the file.
