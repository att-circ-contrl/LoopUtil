function nlPlot_axesPlotExcursions( thisax, ...
  spectfreqs, spectmedian, spectiqr, spectskew, percentlist, ...
  want_relative, figtitle )

% function nlPlot_axesPlotExcursions( thisax, ...
%   spectfreqs, spectmedian, spectiqr, spectskew, percentlist, ...
%   want_relative, figtitle )
%
% This plots LFP power excursions, either as relative power excess alone or
% against the median power spectrum. See nlChan_applySpectSkewCalc() for
% details of skew calculation and array contents.
% The plot is rendered to the specifed set of figure axes.
%
% "thisax" is the "axes" object to render to.
% "spectfreqs" is an array of frequency bin center frequencies.
% "spectmedian" is an array of per-frequency median power values.
% "spectiqr" is an array of per-frequency power interquartile ranges.
% "spectskew" is a cell array, with one cell per "percentlist" value. Each
%   cell contains an array of per-frequency skew values.
% "percentlist" is an array of percentile values that define the tails for
%   skew calculations, per nlProc_calcSkewPercentile().
% "want_relative" is true to plot relative power excess alone, and false to
%   plot against the median power spectrum.
% "figtitle" is the title to use for the figure, or '' for no title.


%
% Render the plot.

% Don't select the axes here; that changes child ordering and other things.
% Instead, explicitly specify the axes to modify for function calls.

hold(thisax, 'on');


if want_relative

  % Normalized excursions alone.

  for pidx = 1:length(percentlist)

    thisskew = spectskew{pidx};
    % Leave the normalized value alone.

    plot( thisax, spectfreqs, thisskew, ...
      'DisplayName', sprintf('excursion skew (%.1f%%)', percentlist(pidx)) );

  end

  ylabel(thisax, 'Relative Power Density Skew');
  set(thisax, 'Yscale', 'linear');

else

  % Excursions against the spectrum.

  plot( thisax, spectfreqs, spectmedian, 'DisplayName', 'background' );

  for pidx = 1:length(percentlist)

    thisskew = spectskew{pidx};
    % Set things up so that skew of 0 is aligned with the median curve.
    thisskew = spectmedian + (thisskew .* spectiqr);

    plot( thisax, spectfreqs, thisskew, ...
      'DisplayName', sprintf('excursion skew (%.1f%%)', percentlist(pidx)) );

  end

  ylabel(thisax, 'Power Density (a.u.)');
  set(thisax, 'Yscale', 'log');

end


hold(thisax, 'off');


% Common components.

if ~strcmp('', figtitle)
  title(thisax, figtitle);
end

legend(thisax, 'Location', 'northeast');

xlim( thisax, [ min(spectfreqs) max(spectfreqs) ] );

xlabel(thisax, 'Frequency (Hz)');
set(thisax, 'Xscale', 'log');



%
% Done.

end


%
% This is the end of the file.
