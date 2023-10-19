function nlPlot_axesPlotSurface2D( thisax, zdata, xvalues, yvalues, ...
  xrange, yrange, xloglin, yloglin, zloglin, xtitle, ytitle, figtitle )

% function nlPlot_axesPlotSurface2D( thisax, zdata, xvalues, yvalues, ...
%   xrange, yrange, xloglin, yloglin, zloglin, xtitle, ytitle, figtitle )
%
% This plots a 2D array of data values as a heatmap or spectrogram style
% plot.
%
% "thisax" is the "axes" object to render to.
% "zdata" is a matrix indexed by (y,x) of data values to plot.
% "xvalues" is a series of X coordinate values corresponding to each column
%   of zdata. If there are as many values as columns, they're bin midpoints.
%   If there's one more value than there are columns, they're bin edges.
% "yvalues" is a series of Y coordinate values corresponding to each row of
%   zdata. If there are as many values as rows, they're bin midpoints. If
%   there's one more value than there are rows, they're bin edges.
% "xrange" [ min max ] is the range of X values to render, or [] for auto.
% "yrange" [ min max ] is the range of Y values to render, or [] for auto.
% "xloglin" is 'log' or 'linear', specifying the X axis scale.
% "yloglin" is 'log' or 'linear', specifying the Y axis scale.
% "zloglin" is 'log' or 'linear', specifying whether to log-compress zdata.
% "xtitle" is the title to use for the X axis, or '' to not set one.
% "ytitle" is the title to use for the Y axis, or '' to not set one.
% "figtitle" is the title to use for the figure, or '' to not set one.
%
% No return value.


% NOTE - Don't select the axes; that changes child ordering and other things.
% Instead, explicitly specify the axes to modify for function calls.


%
% Figure out how many cells on each axis there are, and compute bin edges
% if we don't already have them.

scratch = size(zdata);
xcount = scratch(2);
ycount = scratch(1);

if length(xvalues) == xcount
  xvalues = nlProc_getBinEdgesFromMidpoints(xvalues, xloglin);
end
if length(yvalues) == ycount
  yvalues = nlProc_getBinEdgesFromMidpoints(yvalues, yloglin);
end


% Use the edges to get range limits if these weren't specified.

if isempty(xrange)
  xrange = [ min(xvalues), max(xvalues) ];
end

if isempty(yrange)
  yrange = [ min(yvalues), max(yvalues) ];
end



%
% Expand the data matrix, since we care about faces, not vertices.

zdata(ycount+1,:) = zdata(ycount,:);
zdata(:,xcount+1) = zdata(:,xcount);



%
% Convert Z values to log scale if requested.

if strcmp('log', zloglin)
  % NOTE - Clamp the data to a tolerable minimum positive value.
  % Blithely assume that _some_ of the data is positive.

  clampmin = 1e-8 * max(max(zdata));
  zdata = max(zdata, clampmin);

  zdata = log10(zdata);
end



%
% Render the data.

surf( thisax, xvalues, yvalues, zdata, 'EdgeColor', 'none' );

% Axis type and orientation.
axis(thisax, 'xy');
axis(thisax, 'tight');
view(thisax, 0, 90);

% Make ticks point outwards and be slightly heavier.
thisax.XAxis.TickDirection = 'out';
thisax.YAxis.TickDirection = 'out';
thisax.XAxis.LineWidth = 1;
thisax.YAxis.LineWidth = 1;

% Set log/linear.
set(thisax, 'Xscale', xloglin);
set(thisax, 'Yscale', yloglin);

% Set ranges.
xlim(thisax, xrange);
ylim(thisax, yrange);

% Decorations.

if ~isempty(xtitle)
  xlabel(thisax, xtitle);
end
if ~isempty(ytitle)
  ylabel(thisax, ytitle);
end
if ~isempty(figtitle)
  title(thisax, figtitle);
end


% Done.
end


%
% This is the end of the file.
