function nlPlot_plotExcursions( thisfig, oname, ...
  spectfreqs, spectmedian, spectiqr, spectskew, percentlist, ...
  want_relative, figtitle )

% function nlPlot_plotExcursions( thisfig, oname, ...
%   spectfreqs, spectmedian, spectiqr, spectskew, percentlist, ...
%   want_relative, figtitle )
%
% This plots LFP power excursions, either as relative power excess alone or
% against the median power spectrum. See nlChan_applySpectSkewCalc() for
% details of skew calculation and array contents.
%
% "thisfig" is the figure to render to (this may be a UI component).
% "oname" is the filename to save to, or '' to not save.
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


figure(thisfig);
clf('reset');

% Wrap the "axes" plotting function.

nlPlot_axesPlotExcursions( gca, ...
  spectfreqs, spectmedian, spectiqr, spectskew, percentlist, ...
  want_relative, figtitle );


% Save the plot if we've been given a filename.

if ~strcmp('', oname)
  saveas( thisfig, oname );
end


%
% Done.

end


%
% This is the end of the file.
