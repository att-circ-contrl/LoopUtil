function rampseries = nlArt_getEndpointRamps( dataseries, spanfrac )

% function rampseries = nlArt_getEndpointRamps( dataseries, spanfrac )
%
% This segments a signal into NaN and non-NaN regions, and constructs a
% piecewise-linear background connecting the endpoints of all non-NaN
% regions (defined across the entire data series, including NaN regions).
%
% This is intended to be subtracted before filtering to suppress ringing
% from discontinuities in the signal (stepwise changes over a short time
% interval, or sudden changes in slope when interpolating over longer
% gaps). Since FFT-based filtering assumes the signal is periodic, this also
% suppresses edge effects (by forcing the signal endpoints to match).
%
% "dataseries" is the series to process.
% "spanfrac" is the fraction of the length of non-NaN spans to keep at each
%   endpoint when estimating the line fit (e.g. 0.05 to pay attention to the
%   first and last 5% of each non-NaN segment). This is intended to suppress
%   transient samples at the endpoints. If this is 0 or NaN, only the first
%   and last sample of each non-NaN region are used.
%
% "rampseries" is a piecewise-linear curve defined across the entire range
%   of samples, bridging the endpoints of all non-NaN segments.


rampseries = zeros(size(dataseries));

if ~isfinite(spanfrac)
  spanfrac = 0;
end
if spanfrac < 0
  spanfrac = 0;
end
if spanfrac > 0.5
  spanfrac = 0.5;
end


% Handle the "given an empty list" case.
if isempty(dataseries)
  return;
end


% Handle the "we only have one sample" case.
if length(dataseries) < 2
  % The list is already initialized to zero, which is fine for NaN input.
  if ~isnan(dataseries(1))
    rampseries(1) = dataseries(1);
  end
end


% First pass: Get endpoint values for all non-NaN spans.

[ validstartlist validendlist nanstartlist nanendlist ] = ...
  nlProc_findNaNSpans(dataseries);

pointindices = [];
pointvalues = [];

for vidx = 1:length(validstartlist)

  % Get the data segment we're processing.

  startidx = validstartlist(vidx);
  endidx = validendlist(vidx);

  thistime = startidx:endidx;
  thisdata = dataseries(thistime);

  sampcount = length(thisdata);


  if sampcount < 2
    % If we only have one sample, don't interpolate, just copy.

    pointindices = [ pointindices thistime(1) ];
    pointvalues = [ pointvalues thisdata(1) ];
  else

    % We have at least two samples.
    % Mask off the parts of the span we don't want (copy the endpoints).

    spansamps = round(spanfrac * sampcount);
    spansamps = max(1, spansamps);
    spansamps = min(sampcount, spansamps);

    copymask = false(size(thisdata));
    copymask(1:spansamps) = true;
    copymask((1 + sampcount - spansamps):sampcount) = true;

    thistime = thistime(copymask);
    thisdata = thisdata(copymask);

    % Perform linear interpolation to get interpolated endpoint values.
    % This suppresses brief transients at the endpoints.

    pcoeffs = polyfit( thistime, thisdata, 1 );
    recontime = [ startidx endidx ];
    recondata = polyval( pcoeffs, recontime );

    % Add the two endpoints to the point list.
    % Since we fed it 1xN time samples, we should get 1xN data samples out,
    % so it's safe to use horzcat.
    pointindices = [ pointindices recontime ];
    pointvalues = [ pointvalues recondata ];

  end

end


% Second pass: Augment this with starting and ending points if not already
% present, and render the piecewise-linear wave.

% Handle the "no non-NaN segments" case.
if isempty(pointindices)
  pointindices = [ 1 sampcount ];
  pointvalues = [ 0 0 ];
end

% If starting or ending samples were NaN, extend non-NaN to cover them.
% Make the new segments constant-value.

pointcount = length(pointindices);

if pointindices(pointcount) < sampcount
  pointindices = [ pointindices sampcount ];
  pointvalues = [ pointvalues pointvalues(pointcount) ];
end

if pointindices(1) > 1
  pointindices = [ 1 pointindices ];
  pointvalues = [ pointvalues(1) pointvalues ];
end

% Update the number of piecewise data points.
pointcount = length(pointindices);


% We have at least two data points, all with different indices.
% Render the line segments.

for sidx = 1:(pointcount-1)
  spandeftime = [ pointindices(sidx) pointindices(sidx+1) ];
  spandefdata = [ pointvalues(sidx) pointvalues(sidx+1) ];

  pcoeffs = polyfit( spandeftime, spandefdata, 1 );

  thistime = pointindices(sidx):pointindices(sidx+1);
  thisdata = polyval(pcoeffs, thistime);

  rampseries(thistime) = thisdata;
end


% Done.
end


%
% This is the end of the file.
