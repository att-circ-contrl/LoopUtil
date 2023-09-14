function fitlist = nlFT_guessMultipleExpDecays( ...
  ftdata, fitconfig, want_plots, want_reports, plotconfig, ...
  tattle_verbosity, report_verbosity )

% function fitlist = nlFT_guessMultipleExpDecays( ...
%   ftdata, fitconfig, want_plots, want_reports, plotconfig, ...
%   tattle_verbosity, report_verbosity )
%
% This is a wrapper for nlArt_guessMultipleExpDecays().
%
% This uses black magic to guess where exponential curve fits should be
% performed to remove artifacts. It can be robust but needs a lot of
% fine-tuning.
%
% Plots of curve fit attempts are optionally generated. These are useful
% when hand-tuning the configuration parameters.
%
% "ftdata" is a ft_datatype_raw structure with trial data to process.
% "fitconfig" is a configuration structure, per EXPGUESSCONFIG.txt.
% "want_plots" is true if debug plots of curve fits are to be generated.
% "want_reports" is true if summaries of curve fit progress are to be saved.
% "plotconfig" is a structure with the fields described in EXPGUESSPLOT.txt,
%   or struct([]) to suppress plotting and reports.
% "tattle_verbosity" is 'quiet', 'terse', 'normal', or 'verbose'. This
%   controls how many debugging/progress messages are sent to the console.
% "report_verbosity" is 'quiet', 'terse', 'normal', or 'verbose'. This
%   controls how many debugging/progress messages are written to disk.
%
% "fitlist" is a {ntrials, nchannels} cell array. Each cell array holds a
%   one-dimensional cell array containing curve fit parameters for
%   successive curve fits. Curve fit parameters are structures as described
%   in ARTFITPARAMS.txt.


fitlist = {};

chancount = length(ftdata.label);
trialcount = length(ftdata.trial);

reportstr = '';

if isempty(plotconfig)
  want_plots = false;
  want_reports = false;
end


% Get plotting masks.

trialmask = false(1,trialcount);
chanmask = false(1,chancount);
if want_plots
  % Don't call euPlot_decimatePlotsBresenham; avoid external dependency.

  max_count = plotconfig.max_trial_count;
  plot_thresh = ((trialcount - 1) / trialcount) - 1e-4;
  if max_count > trialcount
    trialmask = true(1,trialcount);
  elseif (~isnan(max_count)) && (max_count > 0)
    scratch = 1:trialcount;
    scratch = ((scratch - 1) * max_count) / trialcount;
    scratch = mod(scratch + 0.5, 1.0);
    trialmask(1,:) = (scratch >= plot_thresh);
  end

  max_count = plotconfig.max_chan_count;
  plot_thresh = ((chancount - 1) / chancount) - 1e-4;
  if max_count > chancount
    chanmask = true(1,chancount);
  elseif (~isnan(max_count)) && (max_count > 0)
    scratch = 1:chancount;
    scratch = ((scratch - 1) * max_count) / chancount;
    scratch = mod(scratch + 0.5, 1.0);
    chanmask(1,:) = (scratch >= plot_thresh);
  end
end


% Perform curve fitting.

for tidx = 1:trialcount
  thistime = ftdata.time{tidx};
  thistrial = ftdata.trial{tidx};

  triallabel = sprintf('tr%03d', tidx);
  trialtitle = sprintf('Tr %03d', tidx);

  for cidx = 1:chancount
    % Don't call euUtil_makeSafeString; avoid external dependency.

    chantitle = ftdata.label{cidx};
    scratch = ((chantitle >= '0') & (chantitle <= '9')) | isletter(chantitle);
    chanlabel = chantitle(scratch);
    chantitle(~scratch) = ' ';


    % Set appropriate titles and labels.

    reportlabel = [ triallabel '-' chanlabel ];

    thisplotconfig = plotconfig;

    if want_plots
      thisplotconfig.fileprefix = ...
        [ plotconfig.fileprefix '-' triallabel '-' chanlabel ];
      thisplotconfig.titleprefix = ...
        [ plotconfig.titleprefix ' - ' trialtitle ' - ' chantitle ];
    end

    % Decimate plots.
    if ~(want_plots & trialmask(tidx) & chanmask(cidx))
      thisplotconfig = struct([]);
    end


    % Do the curve fit on this trial/channel.

    thiswave = thistrial(cidx,:);
    [ newwave thisfitlist thisreport ] = nlArt_guessMultipleExpDecays( ...
      thistime, thiswave, fitconfig, thisplotconfig, ...
      tattle_verbosity, report_verbosity, reportlabel );

    fitlist{tidx,cidx} = thisfitlist;

    reportstr = [ reportstr thisreport ];
  end
end


if want_reports && (~isempty(reportstr))
  reportstr = sprintf( ...
    '-- Curve fit report for %s:\n%s--End of curve fit report.\n', ...
    plotconfig.titleprefix, reportstr );
  nlIO_writeTextFile( [ plotconfig.fileprefix '-curvefits.txt' ], reportstr );
end


% Done.
end


%
% This is the end of the file.
