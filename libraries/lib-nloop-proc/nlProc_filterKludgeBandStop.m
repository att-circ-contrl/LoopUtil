function newwave = nlProc_filterKludgeBandStop( oldwave, samprate, bandlist )

% function newwave = nlProc_filterKludgeBandStop( oldwave, samprate, bandlist )
%
% This performs band-stop filtering in the frequency domain by squashing
% frequency components. This causes ringing near large disturbances (a
% top-hat in the frequency domain gives a sinc function impulse response).
%
% "oldwave" is the signal to filter. This is assumed to be real.
% "samprate" is the sampling rate of "oldwave".
% "bandlist" is a cell array containing [ min max ] tuples indicating
%   frequency ranges to squash.
%
% "newwave" is a filtered version of "oldwave".


% Do this by brute force and ignorance.


% Build a mask of frequencies to squash.

duration = length(oldwave) / samprate;
spectfreqs = ( 0:(length(oldwave)-1) ) / duration;
squashmask = false(size(spectfreqs));

for bidx = 1:length(bandlist)
  thisband = bandlist{bidx};
  squashmask( (spectfreqs >= min(thisband)) ...
    & (spectfreqs <= max(thisband)) ) = true;
end

% We can't quite flip this (the first sample is DC), so do it manually.
fcount = length(squashmask);
squashmask(2:fcount) = squashmask(2:fcount) | squashmask(fcount:-1:2);


% Squash the indicated frequencies.

spectvals = fft(oldwave);
spectvals(squashmask) = 0.0;
newwave = real(ifft(spectvals));


% Done.

end


%
% This is the end of the file.
