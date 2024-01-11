function [ coherence powercorrel nongausscorrel ] = ...
  nlProc_compareSignalsHT( xsignal, ysignal )

% function [ coherence powercorrel nongausscorrel ] = ...
%   nlProc_compareSignalsHT( xsignal, ysignal )
%
% This calculates the coherence, power correlation, and non-Gaussian
% power correlation of two analytic signals using the method described in
% Hindriks 2023.
%
% The power correlation is expressed as the sum of terms that are derived
% from the coherence and the co-kurtosis. The co-kurtosis component is the
% component that departs from Gaussian random variable behavior.
%
% The two signals must have the same number of samples and should be
% complex values encoding magnitude and phase (either from the Hilbert
% transform or from picking a frequency from a time-frequency analysis).
%
% "xsignal" is the first signal to compare.
% "ysignal" is the second signal to compare.
%
% "coherence" is the coherence (a complex value with magnitude <= 1).
% "powercorrel" is the correlation of the squared magnitudes of the signals
%   (a real value between -1 and +1 inclusive).
% "nongausscorrel" is the component of "powercorrel" that is not explained
%   by Gaussian random variable behavior.


% Hindriks 2023 uses the following conventions:
% p_xy is the coherence of x and y.
% r_xy is the Pearson correlation of |x|^2 and |y|^2.
% K_x is the normalized fourth-order joint cumulant of (x,x,conj(x),conj(x)).
% K_y is the normalized fourth-order joint cumulant of (y,y,conj(y),conj(y)).
% K_xy is the normalized fourth-order joint cumulant of (x,y,conj(x),conj(y)).
% K_x and K_y are "excess kurtosis" (historical kurtosis minus 3) of |x|^2.
% K_xy is "cokurtosis".

% Hindriks 2023 uses the following relationship:
% r_xy = ( |p_xy|^2 + K_xy + |p_xconj(y)|^2 ) ...
%   / sqrt( ( 1 + K_x + |p_xconj(x)|^2) * (1 + K_y + |p_yconj(y)|^2) )
% The value of p_aconj(b) and p_aconj(a) vanishes for well-behaved signals.
% We shouldn't assume that, though.

% Matlab will compute K_x but not K_xy; that's enough for us to get the
% term we want.


% The input signals need to be zero-mean.
xsignal = xsignal - mean(xsignal);
ysignal = ysignal - mean(ysignal);


% Coherence terms.

coherence = nlProc_calcCoherenceHT(xsignal, ysignal);

p_xy = coherence;
p_xconjy = nlProc_calcCoherenceHT(xsignal, conj(ysignal));

p_xconjx = nlProc_calcCoherenceHT(xsignal, conj(xsignal));
p_yconjy = nlProc_calcCoherenceHT(ysignal, conj(ysignal));


% Power correlation terms.

% Convert signals to squared magnitudes.
% Force these to be real in case of roundoff errors.
xpower = real( xsignal .* conj(xsignal) );
ypower = real( ysignal .* conj(ysignal) );

% This returns a 2x2 symmetrical matrix; pick an off-diagonal corner.
powercorrel = corrcoef( xpower, ypower );
powercorrel = powercorrel(1,2);

denom = sqrt( (1 + kurtosis(xpower) + abs(p_xconjx) * abs(p_xconjx)) ...
  * (1 + kurtosis(ypower) + abs(p_yconjy) * abs(p_yconjy)) );

gausscorrel = (abs(p_xy) * abs(p_xy) + abs(p_xconjy) * abs(p_xconjy)) / denom;

nongausscorrel = powercorrel - gausscorrel;



% Done.
end


%
% This is the end of the file.
