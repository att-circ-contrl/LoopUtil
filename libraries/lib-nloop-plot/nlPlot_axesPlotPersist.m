function nlPlot_axesPlotPersist( thisax, ...
  persistvals, persistfreqs, persistpowers, want_log, figtitle )

% function nlPlot_plotPersist( thisax, ...
%   persistvals, persistfreqs, persistpowers, want_log, figtitle )
%
% This plots a pre-tabulated persistence spectrum. See "pspectrum()" for
% details of input array structure.
%
% "thisax" is the "axes" object to render to.
% "thisfig" is the figure to render to (this may be a UI component).
% "persistvals" is the matrix of persistence spectrum fraction values.
% "persistfreqs" is the list of frequencies used for binning.
% "persistpowers" is the list of power magnitudes used for binning.
% "want_log" is true if the frequency axis should be plotted on a log scale
%   (it's computed on a linear scale).
% "figtitle" is the title to use for the figure, or '' for no title.


%
% Render the plot.

% Don't select the axes here; that changes child ordering and other things.
% Instead, explicitly specify the axes to modify for function calls.

persistpowers = 10 * log10(persistpowers);

% FIXME - Convert bin percentage counts to log scale for improved visibility.
persistvals = log(persistvals + 1);

surf( thisax, persistfreqs, persistpowers, persistvals, 'EdgeColor', 'none' );
axis(thisax, 'xy');
axis(thisax, 'tight');
view(thisax, 0, 90);
xlabel(thisax, 'Frequency (Hz)');
ylabel(thisax, 'Power (dB)');

set(thisax, 'Yscale', 'linear');
if want_log
  set(thisax, 'Xscale', 'log');
else
  set(thisax, 'Xscale', 'linear');
end

% Make range consistent.
ylim(thisax, [ -30 60 ]);

if ~strcmp('', figtitle)
  title(thisax, figtitle);
end


%
% Done.

end


%
% This is the end of the file.
