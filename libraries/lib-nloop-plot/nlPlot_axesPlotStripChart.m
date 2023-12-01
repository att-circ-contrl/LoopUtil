function nlPlot_axesPlotStripChart( thisax, timeseries, wavematrix, ...
  wavelabels, colstart, colspread, wavestyle, want_axis_labels, ...
  timerange, wave_yrange, wave_yspacing, hcursorlist, hcursorcol, ...
  vcursorlist, vcursorcol, xtitle, ytitle, legendpos, figtitle )

% function nlPlot_axesPlotStripChart( thisax, timeseries, wavematrix, ...
%   wavelabels, colstart, colspread, wavestyle, want_axis_labels, ...
%   timerange, wave_yrange, wave_yspacing, hcursorlist, hcursorcol, ...
%   vcursorlist, vcursorcol, xtitle, ytitle, legendpos, figtitle )
%
% This plots a series of waveforms stacked vertically, strip-chart style.
%
% This is intended to be called multiple times, so that several sets of
% waves and cursors can be added to the same plot axes.
%
% "thisax" is the "axes" object to render to.
% "timeseries" is a vector containing sample times.
% "wavematrix" is a Nchans x Nsamples matrix containing data to plot.
% "wavelabels" is a cell array of length Nchans containing legend labels
%   for each wave. These are also plotted on the Y axis if requested. Empty
%   labels ('') suppress a given wave's label.
% "colstart" is a [ r g b ] colour triplet specifying the colour of the
%   first wave plotted.
% "colspread" is the total angle to walk around the colour wheel while
%   plotting waves, in degrees.
% "wavestyle" is a character vector with the line style to use when plotting.
% "want_axis_labels" is true to render each wave's label next to the Y axis
%   in addition to in the legend, false otherwise.
% "timerange" [ min max ] is the time span to render, or [] to auto-range.
% "wave_yrange" [ min max ] is the Y range to make available for each wave,
%   or [] to auto-range.
% "wave_yspacing" is the Y distance to offset successive waves in the plot,
%   or [] or NaN to auto-range.
% "hcursorlist" is a vector containing Y coordinates for horizontal cursors.
% "hcursorcol" [ r g b ] is the colour to use when rendering horizontal
%   cursors. If there are no cursors, this may be [] or NaN.
% "vcursorlist" is a vector containing X coordinates for vertical cursors.
% "vcursorcol" [ r g b ] is the colour to use when rendering vertical
%   cursors. If there are no cursors, this may be [] or NaN.
% "xtitle" is the title to give to the X axis, or '' to not modify the title.
% "ytitle" is the title to give to the Y axis, or '' to not modify the title.
% "legendpos" is a position specifier to pass to the "legend" command, or
%   'off' to remove the legend, or '' to not alter the legend location.
% "figtitle" is the title to apply to the figure, or '' to not alter the
%   title.
%
% No return value.


% NOTE - For rendering, explicitly specify the axes to modify for each
% function call. Trying to select axes messes with child ordering.


%
% Get metadata.

chancount = length(wavelabels);

if isempty(timerange)
  timerange = [ min(timeseries) max(timeseries) ];
end
timerange = sort(timerange);

if isempty(wave_yrange)
  wave_yrange = [ min(min(wavematrix)) max(max(wavematrix)) ];
  if ~isempty(hcursorlist)
    wave_yrange(1) = min( wave_yrange(1), min(hcursorlist) );
    wave_yrange(2) = max( wave_yrange(2), max(hcursorlist) );
  end
end
wave_yrange = sort(wave_yrange);

if isempty(wave_yspacing) || isnan(wave_yspacing)
  wave_yspacing = 1.2 * ( max(wave_yrange) - min(wave_yrange) );
end

full_yrange = wave_yrange;
full_yrange(1) = full_yrange(1) - (chancount - 1) * wave_yspacing;

if want_axis_labels
  labelx = max( min(timeseries), min(timerange) );
  labeltidx = min(find(timeseries >= labelx));
  if ~isempty(labeltidx)
    labelx = timeseries(labeltidx);
  else
    want_axis_labels = false;
  end
end


%
% Get palette.

wavepalette = nlPlot_getColorSpread(colstart, chancount, colspread);


%
% Render cursors first, so they're under the waveforms and labels.

hold(thisax, 'on');

for hidx = 1:length(hcursorlist)
  for cidx = 1:chancount
    yoffset = wave_yspacing * (cidx - 1);
    thisyval = hcursorlist(hidx) - yoffset;
    plot( thisax, timerange, [ thisyval thisyval ], ...
      'Color', hcursorcol, 'HandleVisibility', 'off' );
  end
end

for vidx = 1:length(vcursorlist)
  plot( thisax, [ vcursorlist(vidx) vcursorlist(vidx) ], full_yrange, ...
    'Color', vcursorcol, 'HandleVisibility', 'off' );
end


%
% Render the strip-chart.

xlim(thisax, timerange);
ylim(thisax, full_yrange);

for cidx = 1:chancount
  thislabel = wavelabels{cidx};
  yoffset = wave_yspacing * (cidx - 1);

  if ~isempty(thislabel)
    plot( thisax, timeseries, wavematrix(cidx,:) - yoffset, ...
      wavestyle, 'Color', wavepalette{cidx}, 'DisplayName', thislabel );

    if want_axis_labels
      labely = wavematrix(cidx,labeltidx) - yoffset;
      text( thisax, labelx, labely, thislabel );
    end
  else
    plot( thisax, timeseries, wavematrix(cidx,:) - yoffset, ...
      wavestyle, 'Color', wavepalette{cidx}, 'HandleVisibility', 'off' );
  end
end

% Finished rendering.
hold(thisax, 'off');


%
% Add decorations.

if ~isempty(xtitle)
  xlabel(thisax, xtitle);
end

if ~isempty(ytitle)
  ylabel(thisax, ytitle);
end

if ~isempty(figtitle)
  title(thisax, figtitle);
end

if ~isempty(legendpos)
  if strcmp('off', legendpos)
    legend(thisax, 'off');
  else
    legend(thisax, 'Location', legendpos);
  end
end



% Done.
end


%
% This is the end of the file.
