function coherence = nlProc_calcCoherence( xsignal, ysignal )

% function coherence = nlProc_calcCoherence( xsignal, ysignal )
%
% This computes the coherence of two analytic signals (signals with
% complex values encoding magnitude and phase). The two signals must have
% the same number of samples.
%
% This uses the formula from Hindriks 2023, which assumes the signals
% are already in the form described above (either from the Hilbert transform
% or from picking a frequency from a STFT analysis).
%
% See "mscohere" and "cpsd" for the Matlab ways to do this.
%
% "xsignal" is the first signal to compare.
% "ysignal" is the second signal to compare.
%
% "coherence" is the coherence (a complex value with magnitude <= 1).


% Hindriks uses:
% coherence = mean(x * conj(y)) / sqrt( mean(|x|^2) mean(|y|^2) )

% We're using "sum" instead of "mean", since the result is the same.
% |x|^2 is equal to x * conj(x).

coherence = sum( xsignal .* conj(ysignal) ) ...
  / sqrt( sum( xsignal .* conj(xsignal) ) * sum( ysignal .* conj(ysignal) ) );


% Done.
end


%
% This is the end of the file.
