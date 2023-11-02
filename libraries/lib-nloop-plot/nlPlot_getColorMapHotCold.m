function newmap = nlPlot_getColorMapHotCold( coldcolor, hotcolor, exponent )

% function newmap = nlPlot_getColorMapHotCold( coldcolor, hotcolor, exponent )
%
% This function returns a Matlab colormap that spans from the "cold" colour
% (negative values), to black, to the "hot" colour (positive values).
%
% This is intended to be used with a "clim" range centred on zero (i.e.
% symmetric).
%
% "coldcolor" [ r g b ] is the colour to use for the most negative end of
%   the colormap. Components are in the range 0..1.
% "hotcolor" [ r g b ] is the colour to use for the most positive end of
%   the colormap. Components are in the range 0..1.
% "exponent" determines the slope of the colour gradient. A value of 1 gives
%   a linear gradient. Values closer to 0 make near-zero data values easier
%   to distinguish.
%
% "newmap" is a Matlab colormap.


gradpoints = 1000;

newmap = zeros( gradpoints + gradpoints + 1, 3 );

weightvec = 1:gradpoints;
weightvec = weightvec / gradpoints;
weightvec = weightvec .^ exponent;

for gidx = 1:gradpoints
  newmap(1 + gradpoints - gidx,1:3) = weightvec(gidx) * coldcolor;
  newmap(1 + gradpoints + gidx,1:3) = weightvec(gidx) * hotcolor;
end


% Done.
end


%
% This is the end of the file.
