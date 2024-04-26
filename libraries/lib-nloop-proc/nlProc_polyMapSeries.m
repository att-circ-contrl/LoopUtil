function newdata = nlProc_polyMapSeries( oldtimes, olddata, order, newtimes )

% function newdata = nlProc_polyMapSeries( oldtimes, olddata, order, newtimes )
%
% This performs a polynomial fit on a sparsely-defined data series, and uses
% this to interpolate data values at a new set of sparse sampling points.
% This handles unusual cases properly (empty lists, NaN entries, etc).
%
% NOTE - Interpolating high-order polynomial fits past the ends of the
% supplied data tends to produce very large values. Use a linear fit if
% you're going to do that.
%
% "oldtimes" is a list of time values for which the data series has known
%   values.
% "olddata" is a list of known data values for these times.
% "order" is the order of the polynomial fit to perform ( 1 = linear ).
% "newtimes" is a list of time values to produce interpolated data values
%   for.
%
% "newdata" is a list of interpolated data values at the requested times.


% Force the input to be sorted and remove NaN cases.
% This tolerates empty lists without trouble.

oldvalid = (~isnan(oldtimes)) & (~isnan(olddata));
oldtimes = oldtimes(oldvalid);
olddata = olddata(oldvalid);

% Sort and remove duplicates, rather than just sorting.
[ oldtimes sortidx invidx ] = unique(oldtimes, 'sorted');
olddata = olddata(sortidx);


% NOTE - Not sorting or filling NaNs in the query time series!
% They'll produce NaNs in the output, which is fine.


% Perform the interpolation. Special-case empty input.

if length(oldtimes) < 1

  % No data. Initialize to zero.
  newdata = zeros([ 1 length(newtimes) ]);

else

  % Adjust the order of the polynomial to be less than the number of
  % points. A zero-order polynomial is valid (constant output).

  order = min( order, length(oldtimes) - 1 );


  % Get the curve fit and then get the interpolated values.

  coefflist = polyfit( oldtimes, olddata, order );

  newdata = polyval( coefflist, newtimes );

end


% Done.
end


%
% This is the end of the file.
