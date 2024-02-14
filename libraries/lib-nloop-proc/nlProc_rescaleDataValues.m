function newdata = nlProc_rescaleDataValues( olddata, oldrange, methods )

% function newdata = nlProc_rescaleDataValues( olddata, oldrange, methods )
%
% This function rescales data values in a matrix to map from a user-specified
% input range to the range 0..1.
%
% "olddata" is a matrix to rescale. Data should be real-valued.
% "oldrange" [ min max ] specifies the the desired input range to map.
% "methods" { low high } specifies how to map values that to beyond the low
%   or high endpoint of the desired input range:
%   'nan' or 'NaN' replaces the out-of-range input with NaN.
%   'clamp' replaces the out-of-range input with the limit value.
%   'sigmoid' uses a sigmoid function to map out-of-range values to in-range
%     values.
%
% "newdata" is a copy of "olddata" with in-range inputs mapped to 0..1.


% Initialize.
newdata = olddata;


% Get input parameters.

minmethod = methods{1};
maxmethod = methods{2};


%
% First pass: Perform sigmoid remapping if requested.

% If we have a double-sided sigmoid, map the input range to -2..+2.
% Otherwise, map it to -2..0 or 0..+2 and shift/expand the output.

want_min_sigmoid = strcmp(minmethod, 'sigmoid');
want_max_sigmoid = strcmp(maxmethod, 'sigmoid');

if want_min_sigmoid && want_max_sigmoid
  newdata = helper_mapLinear( newdata, oldrange, [ -2 2 ] );
  newdata = helper_mapSigmoid( newdata );
  oldrange = [ 0 1 ];
  minmethod = 'clamp';
  maxmethod = 'clamp';
elseif want_min_sigmoid
  newdata = helper_mapLinear( newdata, oldrange, [ -2 0 ] );
  newdata = helper_mapSigmoid( newdata );
  oldrange = [ 0 0.5 ];
  minmethod = 'clamp';
elseif want_max_sigmoid
  newdata = helper_mapLinear( newdata, oldrange, [ 0 2 ] );
  newdata = helper_mapSigmoid( newdata );
  oldrange = [ 0.5 1 ];
  maxmethod = 'clamp';
end


%
% Second pass: Perform linear mapping and clamping.

newdata = helper_mapLinear( newdata, oldrange, [ 0 1 ] );

abovemask = (newdata > 1);
belowmask = (newdata < 0);

if strcmp(minmethod, 'clamp')
  newdata(belowmask) = 0;
else
  newdata(belowmask) = NaN;
end

if strcmp(maxmethod, 'clamp')
  newdata(abovemask) = 0;
else
  newdata(abovemask) = NaN;
end


% Done.
end


%
% Helper Functions


% This does a linear mapping to map an old range to a new range.

function newvals = helper_mapLinear(oldvals, oldrange, newrange)

  % Shift to 0..x.
  newvals = oldvals - min(oldrange);

  % Scale to 0..y.
  diffold = max(oldrange) - min(oldrange);
  diffnew = max(newrange) - min(newrange);
  newvals = newvals * (diffnew / diffold);

  % Shift to min..max.
  newvals = newvals + min(newrange);

end


% This does a sigmoid mapping of input data using the logistics function.

function newvals = helper_mapSigmoid(oldvals)

  newvals = exp(-oldvals);
  newvals = 1 ./ (newvals + 1);

end


%
% This is the end of the file.
