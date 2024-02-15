function nlPlot_axesBasicArrow( thisax, xvals, yvals, linewidth, color, ...
  headwidth, headlength, headtype )

% function nlPlot_axesBasicArrow( thisax, xvals, yvals, linewidth, color, ...
%   headwidth, headlength, headtype )
%
% This renders an arrow directly (rather than fighting with "annotation" or
% "quiver", each of which has significant drawbacks).
%
% This calls "plot" to do the rendering.
%
% "thisax" is the axis object to render to.
% "xvals" [ x1 x2 ] is the arrow's X coordinates. The head is at x2.
% "yvals" [ x1 x2 ] is the arrow's Y coordinates. The head is at y2.
% "linewidth" is the width of the lines to draw, in points.
% "color" [ r g b ] is the colour to use when drawing the arrow.
% "headwidth" is the width of the base of the head, in axis coordinates.
% "headlength" is the length of the head, in axis coordinates.
% "headtype" is one of the following:
%   'vee' - Open arrowhead made from two lines.
%   'outline' - Triangle outline made from three lines.
%   'filled' - Filled triangle. FIXME - NYI.
%
% No return value.


xstart = xvals(1);
xend = xvals(2);
ystart = yvals(1);
yend = yvals(2);


% Get a unit vector pointing in the direction of the line.

dx = xend - xstart;
dy = yend - ystart;

scratch = abs(dx + i * dy);
dx = dx / scratch;
dy = dy / scratch;


% Use this to get the head length and base half-width vectors.

xhead = dx * headlength;
yhead = dy * headlength;

% To rotate 90 degrees, x <- y, and y <- (-x).
xbase = 0.5 * dy * headwidth;
ybase = - 0.5 * dx * headwidth;


% Use those to get the two head coordinates.

xleft = (xend - xhead) - xbase;
yleft = (yend - yhead) - ybase;
xright = (xend - xhead) + xbase;
yright = (yend - yhead) + ybase;


% Build the arrow path.

% Default to unfilled triangle.

% Draw the last edge twice for consistent rounding.
xseries = [ xleft xend xright xleft xend ];
yseries = [ yleft yend yright yleft yend ];

% Don't draw the arrow shaft through the head.
xline = [ xstart (xend - xhead) ];
yline = [ ystart (yend - yhead) ];

if strcmp('vee', headtype)
  xseries = [ xleft xend xright ];
  yseries = [ yleft yend yright ];

  xline = [ xstart xend ];
  yline = [ ystart yend ];
end


% Render the arrow.

% Remember the old hold state.
oldnextplot = thisax.NextPlot;

% Use the user's hold setting for the first line.
plot( thisax, xline, yline, 'HandleVisibility', 'off', ...
  'LineWidth', linewidth, 'Color', color );

% Turn hold on for the arrowhead line.
hold on;

plot( thisax, xseries, yseries, '-', 'HandleVisibility', 'off', ...
  'LineWidth', linewidth, 'Color', color );

% Restore the old hold state.
thisax.NextPlot = oldnextplot;


% Done.
end


%
% This is the end of the file.
