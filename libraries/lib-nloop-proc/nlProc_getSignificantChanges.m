function sigmask = nlProc_getSignificantChanges( ...
  meanbefore, devbefore, meanafter, devafter, minsigma )

% function sigmask = nlProc_getSignificantChanges( ...
%   meanbefore, devbefore, meanafter, devafter, minsigma )
%
% This builds a mask indicating which elements of the input had
% statistically significant changes between "before" and "after" states.
%
% This tolerates NaN values.
%
% "meanbefore" is a vector or matrix with "before" measurements.
% "devbefore" is a vector or matrix with standard deviations of "meanbefore".
% "meanafter" is a vector or matrix with "after" measurements.
% "devafter" is a vector or matrix with standard deviations of "meanafter".
% "minsigma" is the number of standard deviations of difference between means
%   needed for a change to be significant.
%
% "sigmask" is a boolean vector or matrix that's "true" for elements of
%   the input with statistically significant changes and "false" otherwise.


% Use the larger of the two standard deviations to get the threshold.
maxdev = max(devbefore, devafter);
absdiff = abs(meanafter - meanbefore);

% NOTE - We're using >, rather than >=, to handle the case where both the
% difference and the deviation are zero (which should return false).
sigmask = ( absdiff > (minsigma * maxdev) );

% If any input values were NaN, set the output to "false" for that cell.
squashmask = isnan(meanbefore) | isnan(meanafter) ...
  | isnan(devbefore) | isnan(devafter);
sigmask(squashmask) = false;


% Done.
end


%
% This is the end of the file.
