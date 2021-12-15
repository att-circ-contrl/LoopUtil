function nlPlot_plotPersist( thisfig, oname, ...
  persistvals, persistfreqs, persistpowers, want_log, figtitle )

% function nlPlot_plotPersist( thisfig, oname, ...
%   persistvals, persistfreqs, persistpowers, want_log, figtitle )
%
% This plots a pre-tabulated persistence spectrum. See "pspectrum()" for
% details of input array structure.
%
% "thisfig" is the figure to render to (this may be a UI component).
% "oname" is the filename to save to, or '' to not save.
% "persistvals" is the matrix of persistence spectrum fraction values.
% "persistfreqs" is the list of frequencies used for binning.
% "persistpowers" is the list of power magnitudes used for binning.
% "want_log" is true if the frequency axis should be plotted on a log scale
%   (it's computed on a linear scale).
% "figtitle" is the title to use for the figure, or '' for no title.


figure(thisfig);
clf('reset');

% Wrap the "axes" plotting function.

nlPlot_axesPlotPersist( gca, ...
  persistvals, persistfreqs, persistpowers, ...
  want_log, figtitle );

%
% Save the plot if we've been given a filename.

if ~strcmp('', oname)
  saveas( thisfig, oname );
end


%
% Done.

end


%
% This is the end of the file.
