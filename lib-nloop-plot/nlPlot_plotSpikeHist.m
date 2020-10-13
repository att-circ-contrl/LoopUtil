function nlPlot_plotSpikeHist( thisfig, oname, ...
  bincounts, binedges, percentamps, percentpers, figtitle )

% function nlPlot_plotSpikeHist( thisfig, oname, ...
%   bincounts, binedges, percentamps, percentpers, figtitle )
%
% This plots a pre-tabulated histogram of normalized spike waveform
% amplitude. For channels with real spikes, tails are asymmetrical.
%
% "thisfig" is the figure to render to (this may be a UI component).
% "oname" is the filename to save to, or '' to not save.
% "bincounts" is an array containing bin count values, per histogram().
% "binedges" is an array containing the histogram bin edges, per histogram().
% "percentamps" is an array of normalized amplitudes corresponding to desired
%   tail percentiles to highlight. Entries 1..N are tail percentile amplitudes,
%   entry N+1 is the median, and entries N+2..2N+1 are (100%-tail) amplitudes.
% "percentpers" is an array naming desired tail percentiles to highlight.
% "figtitle" is the title to use for the figure, or '' for no title.


figure(thisfig);
clf('reset');

% Wrap the "axes" plotting function.

nlPlot_axesPlotSpikeHist( gca, ...
  bincounts, binedges, percentamps, percentpers, figtitle );


% Save the plot if we've been given a filename.

if ~strcmp('', oname)
  saveas( thisfig, oname );
end


%
% Done.

end


%
% This is the end of the file.
