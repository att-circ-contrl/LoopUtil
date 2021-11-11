function sampdistances = nlProc_impedanceCalcDistanceToOrthoGauss( ...
  sampmags, sampphases, magmean, magdev, phasemean, phasedev )

% function sampdistances = nlProc_impedanceCalcDistanceToOrthoGauss( ...
%   sampmags, sampphases, magmean, magdev, phasemean, phasedev )
%
% Given a set of impedance measurements (or other magnitude/phase data
% points), this computes the distance between each measurement and the
% center of a normal distribution with principal axes parallel to the
% magnitude and phase axes.
%
% Distance is expressed in standard deviations.
%
% "sampmags" is a series of impedance magnitude measurements (typically the
%   logarithm of the actual magnitude).
% "sampphases" is a series of impedance phase measurements, in radians.
% "magmean" is the magnitude distribution's mean.
% "magdev" is the magnitude distribution's standard deviation.
% "phasemean" is the phase distribution's circular mean.
% "phasedev" is the standard deviation of (phase - phase mean). This is
%   assumed to be much smaller than 2pi.
%
% "sampdistances" is a series of scalar values indicating how many standard
%   deviations away from the mean each measurement is. This is the L2 norm
%   of the distances from the magnitude and phase means.


% Magnitude distance is straightforward.
magdist = (sampmags - magmean) / magdev;

% For phase distance, remember to wrap to +/- pi.
phasedist = sampphases - phasemean;
phasedist = mod(phasedist + pi, 2*pi) - pi;
phasedist = phasedist / phasedev;

% Take the L2 norm to get distance (as if we were doing PCA).
sampdistances = sqrt( (magdist .* magdist) + (phasedist .* phasedist) );


% Done.

end


%
% This is the end of the file.
