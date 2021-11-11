function [ magmean, magdev, phasemean, phasedev ] = ...
  nlProc_impedanceFitOrthoGauss(membermags, memberphases)

% function [ magmean, magdev, phasemean, phasedev ] = ...
%   nlProc_impedanceFitOrthoGauss(membermags, memberphases)
%
% Given a set of impedance measurements (or other magnitude/phase data
% points), this independently estimates mean and deviation for impedance
% magnitude and phase angle.
%
% Magnitude uses the arithmetic mean. Phase uses the circular mean, but
% linear deviation (we're assuming deviation is much smaller than 2pi).
%
% "membermags" is a series of magnitude measurements. These are evaluated
%   on a linear scale; they're typically the logarithm of actual magnitude.
% "memberphases" is a series of phase measurements, in radians.
%
% "magmean" is the arithmetic mean of "membermags".
% "magdev" is the standard deviation of "membermags".
% "phasemean" is the circular mean of "memberphases".
% "phasedev" is the standard deviation of (memberphases - phasemean).


magmean = mean(membermags);
magdev = std(membermags);

scratch = exp(i * memberphases);
phasemean = angle(mean(scratch));

scratch = memberphases - phasemean;
% Wrap to -pi..pi so that we have the maximum range around the mean.
scratch = mod(scratch + pi, 2*pi) - pi;
phasedev = std(scratch);


% Done.

end


%
% This is the end of the file.
