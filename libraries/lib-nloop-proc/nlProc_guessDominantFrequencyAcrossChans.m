function [ estfreq estmag ] = nlProc_guessDominantFrequencyAcrossChans( ...
  wavedata, samprate, freqrange, method )

% function [ estfreq estmag ] = nlProc_guessDominantFrequencyAcrossChans( ...
%   wavedata, samprate, freqrange, method )
%
% This function identifies the highest-magnitude frequency component within
% a set of supplied waveforms and extracts its frequency and amplitude.
%
% How it does this depends on the "method" argument. For 'average', the
% mean across channels is taken, and that mean signal is analyzed. For
% 'largest', channels are analyzed individually and the response with the
% largest magntiude is chosen. For 'all', channels are analyzed individually
% and the dominant component of each channel is reported.
%
% "wavedata" is a Nchans x Nsamples matrix containing waveform data.
% "samprate" is the sampling rate of the waveform data.
% "freqrange" [ min max ] is the range of frequencies to consider.
% "method" is 'average', 'largest', or 'all'.
%
% "estfreq" is the estimated frequency of the largest component, or a
%   Nchans x 1 vector of frequencies for the 'all' method.
% "extmag" is the magnitude of the largest frequency component, or a
%   Nchans x 1 vector of magnitudes for the 'all' method.


estfreq = NaN;
estmag = NaN;

chancount = size(wavedata);
chancount = chancount(1);


if strcmp(method, 'average')

  wavemean = mean(wavedata, 1);
  [ estfreq estmag ] = ...
    nlProc_guessDominantFrequency( wavemean, samprate, freqrange );

elseif strcmp(method, 'largest') || strcmp(method, 'all')

  % Build per-channel guesses.

  estfreq = [];
  estmag = [];
  for cidx = 1:chancount
    [ thisfreq thismag ] = ...
      nlProc_guessDominantFrequency( wavedata(cidx,:), samprate, freqrange );
    estfreq(cidx,1) = thisfreq;
    estmag(cidx,1) = thismag;
  end


  % If we want "largest", select one result and discard the rest.

  if strcmp(method, 'largest')
    chosenmag = max(estmag);
    chosenidx = min(find( estmag >= (chosenmag * 0.999) ));

    estfreq = estfreq(chosenidx);
    estmag = estmag(chosenidx);
  end

else
  disp([ '### [nlProc_guessDominantFrequencyAcrossChans]  ' ...
    'unknown method "' method '" specified.' ]);
end


% Done.
end


%
% This is the end of the file.
