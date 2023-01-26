function [ cmean cvar lindev ] = nlProc_calcCircularStats( angleseries )

% function [ cmean cvar lindev ] = nlProc_calcCircularStats( angleseries )
%
% This calculates the circular mean, circular variance, and linear standard
% deviation for a specified series of angles.
%
% "angleseries" is a vector containing angles in radians.
%
% "cmean" is the circular mean of the angle series.
% "cvar" is the circular variance of the angle series. Phase locking value
%   is (1 - cvar).
% "lindev" is the linear standard deviation of the angle series. For tightly
%   clustered angles, this can be more intuitive than circular variance.


% Get the circular mean and variance.

vecavg = mean( exp(i * angleseries) );
cvar = 1 - abs(vecavg);
cmean = angle(vecavg);


% Subtract the mean angle and get the linear standard deviation.

angleseries = angleseries - cmean;
angleseries = mod( angleseries + pi, 2*pi ) - pi;

lindev = std(angleseries);


% Done.
end


%
% This is the end of the file.
