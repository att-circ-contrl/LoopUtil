function fitwave = ...
  nlArt_calcSlidingWindowPolyFit( srcwave, winsamps, polyorder, stridesamps )

% function fitwave = ...
%   nlArt_calcSlidingWindowPolyFit( srcwave, winsamps, polyorder, stridesamps )
%
% This performs a polynomial fit within a sliding window, returning a signal
% reconstructed by evaluating the polynomial at the window's midpoint.
%
% This functions as a low-pass filter with a corner wavelength comparable
% to the window size.
%
% NOTE - Evaluating the window for every sample will take a while for large
% window sizes and high sampling rates. Decimate using "stride" to speed
% this up.
%
% "srcwave" is the signal to curve fit.
% "winsamps" is the number of samples in the sliding window.
% "polyorder" is the order of the polynomial to fit.
% "stridesamps" is the number of samples by which to slide the window on
%   each step.
%
% "fitwave" is the smoothed signal produced by the sliding window curve fit.


% Initialize to a safe return value.
fitwave = nan(size(srcwave));


% Get the window radius. Make sure it's at least 1.
winrad = round(0.5 * (winsamps - 1));
winrad = max(winrad, 1);

% Precompute in-window times.
wintimes = (-winrad):winrad;


% Walk through the input, curve fitting at each stride point.
% FIXME - This is a brute force implementation. There's probably a faster way.

% Make a padded input wave, for convenience.
sampcount = length(srcwave);
padwave = NaN([ 1 (sampcount + winrad + winrad) ]);
padwave( (1 + winrad):(sampcount+winrad) ) = srcwave(:);

for sidx = 1:stridesamps:sampcount
  % (sidx - winrad) + winrad to (sidx + winrad) + winrad.
  thiswave = padwave( sidx:(sidx + winrad + winrad) );

  % Get rid of NaN regions.
  validmask = ~isnan(thiswave);

  if any(validmask)
    thiswave = thiswave(validmask);
    thistime = wintimes(validmask);

    coeffs = polyfit(thistime, thiswave, polyorder);

    % This should just be the value of the last coefficient.
    fitwave(sidx) = polyval(coeffs, 0);
  end
end


% Interpolate between our stride points. This also handles endpoints.
fitwave = nlProc_interpolateSeries(1:sampcount, fitwave, 1:sampcount );


% Done.
end


%
% This is the end of the file.
