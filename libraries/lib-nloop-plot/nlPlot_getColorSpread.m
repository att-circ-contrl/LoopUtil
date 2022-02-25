function colorlist = nlPlot_getColorSpread(origcol, count, anglespan)

% function colorlist = nlPlot_getColorSpread(origcol, count, anglespan)
%
% This function takes a starting color and turns it into a spectrum of
% nearby colors, by walking around the color wheel starting with the original
% color.
%
% The resulting sequence is returned as a cell array of color vectors.
%
% "origcol" [ r g b ] is the starting color.
% "count" is the number of colors to return.
% "anglespan" (degrees) is the distance to walk along the color wheel.
%
% "colorlist" is a cell array of the resulting [r g b] color vectors.


% Initialize to a reasonable default.
colorlist = { origcol };


% FIXME - Bail out immediately if we don't have enough points to generate
% a spread.
if count < 2
  return;
end


%
% Break this down into something HSV-like.

% That traditionally uses piecewise-linear blending, which makes CMY look
% brighter than RGB. Use trig blending instead.

greylevel = min(origcol);
satcol = origcol - greylevel;
huerad = sqrt(sum(satcol .* satcol));
satcol = satcol / huerad;

% Handle the pure-grey case.
if isinf(max(satcol))
  satcol = [ 1 0 0 ];
end

% "satcol" now has unit length and has one component as zero.

redval = satcol(1);
greenval = satcol(2);
blueval = satcol(3);

% atan(0..inf) gives a range of 0..pi/2. Map that to 0..(2/3)*pi.
if redval < 1e-6
  % No red component. G..B range.
  hueangle = (2/3) * pi + (4/3) * atan(blueval / greenval);
elseif greenval < 1e-6
  % No green component. B..R range.
  hueangle = (4/3) * pi + (4/3) * atan(redval / blueval);
else
  % No blue component. R..G range.
  hueangle = (4/3) * atan(greenval / redval);
end


%
% Interpolate hue angle and reconstruct colors.

if count < 2
  colorlist = { origcol };
else
  anglespan = anglespan * pi / 180;
  anglestep = anglespan / (count - 1);
  anglevals = 1:count;
  anglevals = (anglevals - 1) * anglestep;
  anglevals = anglevals + hueangle;
  anglevals = mod(anglevals, 2*pi);

  % We could set this up as a vector operation, but sequential is more
  % readable.

  colorlist = {};
  for aidx = 1:count
    hueangle = anglevals(aidx);

    redval = 0;
    greenval = 0;
    blueval = 0;

    % Angle was wrapped to 0..2pi.
    % Expand it to cover 0..(3/2)*pi so we can take piecewise ranges.
    hueangle = hueangle * (3/4);
    if hueangle < (pi/2)
      redval = cos(hueangle);
      greenval = sin(hueangle);
    elseif hueangle < pi
      greenval = cos(hueangle - (pi/2));
      blueval = sin(hueangle - (pi/2));
    else
      blueval = cos(hueangle - pi);
      redval = sin(hueangle - pi);
    end

    % Convert hue back into the appropriate color and store it.
    thiscol = [ redval, greenval, blueval ];
    thiscol = (thiscol * huerad) + greylevel;
    colorlist{aidx} = thiscol;
  end
end


% NOTE - We're sometimes getting huerad + greylevel > 1.
% This happens when we have a magnitude greater than unity. This is valid;
% our colour space is a cube, not a sphere, and we're using spherical
% geometry.
% We have to flag and fix situations where this results in invalid output.

maxcomponent = 0;
for cidx = 1:length(colorlist)
  maxcomponent = max( maxcomponent, max(colorlist{aidx}) );
end

if maxcomponent > 1.0
  for cidx = 1:length(colorlist)
    colorlist{cidx} = colorlist{cidx} / maxcomponent;
  end
end


% Done.

end


%
% This is the end of the file.
