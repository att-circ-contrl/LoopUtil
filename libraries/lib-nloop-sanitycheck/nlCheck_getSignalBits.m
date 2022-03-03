function signalbits = nlCheck_getSignalBits( wavedata )

% function signalbits = nlCheck_getSignalBits( wavedata )
%
% This computes the number of bits of dynamic range in a signal.
% The number will only be meaningful with integer data (i.e. with a minimum
% step size of 1.0).
%
% "wavedata" is a vector containing waveform data samples.
%
% "signalbits" is a floating-point value containing the number of bits
%   needed to represent the waveform data.


thismax = double(max(wavedata));
thismin = double(min(wavedata));

signalbits = log(thismax - thismin) / log(2);


% Done.

end


%
% This is the end of the file.
