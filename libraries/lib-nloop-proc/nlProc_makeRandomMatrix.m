function newmatrix = nlProc_makeRandomMatrix( ...
  rowcount, columncount, datarange, rangeexponent )

% function newmatrix = nlProc_makeRandomMatrix( ...
%   rowcount, columncount, datarange, rangeexponent )
%
% This fills an N x M matrix with random values drawn from a uniform
% distribution, and then raises the magnitues of these values to the specified
% exponent (preserving sign).
%
% The original uniform distribution has a range chosen such that the
% transformed matrix values span the desired range.
%
% Exponent values greater than 1 tend to produce mostly small values with a
% few large values. Exponent values less than 1 tend to do the opposite.
%
% "rowcount" is the number of rows in the output matrix.
% "columncount" is the number of columns in the output matrix.
% "datarange" [ min max ] is the desired range of output values.
% "rangeexponent" is the power to raise magnitudes to.
%
% "newmatrix" is a N x M matrix with cell values spanning the specified range.


% Convert the requested range fenceposts into their nth roots.

minval = min(datarange);
maxval = max(datarange);

minsign = sign(minval);
maxsign = sign(maxval);

minval = abs(minval) ^ (1/rangeexponent);
maxval = abs(maxval) ^ (1/rangeexponent);

minval = minval * minsign;
maxval = maxval * maxsign;


% Get uniformly distributed cell values in the modified range.

valspan = maxval - minval;
newmatrix = rand(rowcount,columncount);
newmatrix = newmatrix * valspan + minval;


% Raise the magnitues to the specified exponents.

signmatrix = sign(newmatrix);
newmatrix = abs(newmatrix) .^ rangeexponent;
newmatrix = newmatrix .* signmatrix;


% Done.
end


%
% This is the end of the file.
