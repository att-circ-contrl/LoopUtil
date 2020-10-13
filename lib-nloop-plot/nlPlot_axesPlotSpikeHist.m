function nlPlot_axesPlotSpikeHist( thisax, ...
  bincounts, binedges, percentamps, percentpers, figtitle )

% function nlPlot_plotSpikeHist( thisax, ...
%   bincounts, binedges, percentamps, percentpers, figtitle )
%
% This plots a pre-tabulated histogram of normalized spike waveform
% amplitude. For channels with real spikes, tails are asymmetrical.
%
% "thisax" is the "axes" object to render to.
% "bincounts" is an array containing bin count values, per histogram().
% "binedges" is an array containing the histogram bin edges, per histogram().
% "percentamps" is an array of normalized amplitudes corresponding to desired
%   tail percentiles to highlight. Entries 1..N are tail percentile amplitudes,
%   entry N+1 is the median, and entries N+2..2N+1 are (100%-tail) amplitudes.
% "percentpers" is an array naming desired tail percentiles to highlight.
% "figtitle" is the title to use for the figure, or '' for no title.

colbrn = [ 0.8 0.4 0.7 ];
colyel = [ 0.9 0.7 0.1 ];
colgrn = [ 0.5 0.7 0.2 ];
colcyn = [ 0.3 0.7 0.9 ];
colmag = [ 0.5 0.2 0.5 ];
colred = [ 0.6 0.1 0.2 ];

collut = { colbrn, colyel, colgrn, colcyn, colmag, colred };


%
% Render the plot.

% Don't select the axes here; that changes child ordering and other things.
% Instead, explicitly specify the axes to modify for function calls.

hold(thisax, 'on');

histogram( thisax, 'BinEdges', binedges, 'BinCounts', bincounts, ...
  'HandleVisibility', 'off' );

% Render percentile limits on top of this.
pcount = length(percentpers);
vertseries = [ 1 1e7 ];

for pidx = 1:pcount
  thiscol = collut{ 1 + mod((pidx-1), length(collut)) };

  % NOTE - The caller should normalize this to match the bin scale.
  thismin = percentamps(pidx);
  thismax = percentamps(1 + pcount + pidx);

  minseries = [ thismin thismin ];
  maxseries = [ thismax thismax ];
  plot( thisax, minseries, vertseries, 'Color', thiscol, ...
    'DisplayName', sprintf('%.3f%% percentile', percentpers(pidx)) );
  plot( thisax, maxseries, vertseries, 'Color', thiscol, ...
    'HandleVisibility', 'off' );
end

hold(thisax, 'off');

xlim( thisax, [ -20 20 ] );
set(thisax, 'Xscale', 'linear');
% We need to be able to see tail details.
set(thisax, 'Yscale', 'log');

legend(thisax, 'Location', 'northeast');

if ~strcmp('', figtitle)
  title(thisax, figtitle);
end

xlabel(thisax, 'Amplitude (IQR)');
ylabel(thisax, 'Count');


%
% Done.

end


%
% This is the end of the file.
