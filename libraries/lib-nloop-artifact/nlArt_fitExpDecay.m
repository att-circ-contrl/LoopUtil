function fitparams = ...
  nlArt_fitExpDecay( timeseries, waveseries, offset, method )

% function fitparams = ...
%   nlArt_fitExpDecay( timeseries, waveseries, offset, method )
%
% This fits an exponential function with the form:
%   f(t) = coeff * exp( t/tau ) + offset
%
% This is intended for artifact curve-fitting.
%
% "timeseries" is a vector with sample timestamps.
% "waveseries" is a vector with sample values to be curve-fit.
% "offset" is a scalar specifying an offset value, [ tmin tmax ] specifying
%   a time range to estimate the offset value from, or [] or NaN to let this
%   function guess at the offset by whatever means it sees fit.
% "method" is a character vector specifying the algorithm to use to perform
%   the exponential fit.
%   'log' does a line fit in the logarithmic domain.
%   'pinmax' pins the curve fit at the most extreme end.
%   'pinboth' pins the curve fit at both ends and jointly optimizes tau and
%     offset.
%
% "fitparams" is a structure with curve fit parameters per ARTFITPARAMS.txt.


fitparams = struct( 'fittype', 'bogus' );


%
% If we've been asked to calculate an offset, calculate one.

if isnan(offset) || isempty(offset)

  % Average the first and last 20% and pick whichever is closest to the mean.

  mintime = min(timeseries);
  maxtime = max(timeseries);
  spantime = 0.2 * (maxtime - mintime);

  thismask = (timeseries <= (mintime + spantime));
  meanfirst = mean(waveseries(thismask));

  thismask = (timeseries >= (maxtime - spantime));
  meanlast = mean(waveseries(thismask));

  meanglobal = mean(waveseries);
  if abs(meanglobal - meanfirst) < abs(meanglobal - meanlast)
    offset = meanfirst;
  else
    offset = meanlast;
  end

elseif length(offset) > 1
  % This should be a time range. Average it.
  thismask = (timeseries >= min(offset)) & (timeseries <= max(offset));
  offset = mean(waveseries(thismask));
else
  % Offset was specified as a scalar. Leave it as-is.
end



%
% Get intermediate information common to several methods.

shiftwave = waveseries - offset;

minval = min(shiftwave);
maxval = max(shiftwave);

if abs(minval) > abs(maxval)
  limitval = minval;
else
  limitval = maxval;
end

% Build a "test mask" for samples that are not too close to zero.
% Find out where extreme values are too, while we're at it.
if limitval > 0
  testmask = (shiftwave >= 0.01 * limitval);
  limitmask = (shiftwave >= 0.9999 * limitval);
else
  testmask = (shiftwave <= 0.01 * limitval);
  limitmask = (shiftwave <= 0.9999 * limitval);
end

% Get the portion of the wave that we want to curve fit.
testtimes = timeseries(testmask);
testwave = shiftwave(testmask);

% Get the location of the most extreme point.
% If there are several candidates, pick the first one.
% FIXME - We should pick one of the endpoints! Outliers in the middle will
% contaminate this.
limitidx = min(find(limitmask));
limittime = testtimes(limitidx);


%
% Perform the fit.
% There are several ways to do this, each with their own drawbacks.

if strcmp(method, 'log')

  % Fit coeff and tau but not offset.

  % Line fit in the log domain to get tau.

  if limitval > 0
    logwave = log(testwave);
  else
    % Negate so we can take the logarithm.
    logwave = log(-testwave);
  end

  pfit = polyfit(testtimes, logwave, 1);

  omega = pfit(1);
  coeff = exp(pfit(2));

  if limitval < 0
    coeff = -coeff;
  end


  % Use a least-squares fit in the linear domain to get coeff.
  % The log domain fit is dominated by the (noisy) tail, and we care more
  % about the high-amplitude part.

  if true
    testexp = exp(testtimes * omega);
    coeff = sum(testwave .* testexp) / sum(testexp .* testexp);
  end


  % Save the fit parameters.

  fitparams = struct( 'fittype', 'exp', ...
    'coeff', coeff, 'tau', 1 / omega, 'offset', offset );

elseif strcmp(method, 'pinmax')

  % Fit coeff and tau but not offset.

  % Pin the maximum point, and fit both omega and coeff.
  % Do this by optimizing d * exp(w(t-t0)), then converting back.
  % d = f(t0) = limitval, so we don't need to compute it explicitly.
  % Using "testwave / limitval" ensures that we're taking the log of a
  % positive value even if limitval and testwave are negative.

  shifttimes = testtimes - limittime;
  omega = sum( shifttimes .* log(testwave / limitval) ) ...
    / sum( shifttimes .* shifttimes );

  % d*exp(w(t-t0)) = d*exp(wt)*exp(-wt0) = c*exp(wt)
  % So, c = d*exp(-wt0).

  coeff = limitval * exp( - omega * limittime );

  % Save the fit parameters.
  fitparams = struct( 'fittype', 'exp', ...
    'coeff', coeff, 'tau', 1 / omega, 'offset', offset );

elseif strcmp(method, 'pinboth')

  % FIXME - NYI.
  disp([ '### [nlArt_fitExpDecay]  Method "pinboth" not yet implemented.' ]);

else

  disp([ '### [nlArt_fitExpDecay]  Unknown curve fit method "' method '".' ]);

end


% Done.
end



%
% This is the end of the file.
