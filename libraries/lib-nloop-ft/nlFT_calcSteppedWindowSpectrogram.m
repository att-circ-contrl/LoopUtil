function [ freqlist timelist spectpowers ] = ...
  nlFT_calcSteppedWindowSpectrogram( ...
    ftdata, winsize, winstep, timespan, freqspan )

% function [ freqlist timelist spectpowers ] = ...
%   nlFT_calcSteppedWindowSpectrogram( ...
%     ftdata, winsize, winstep, timespan, freqspan )
%
% This computes a spectrogram of Field Trip data using a stepped rectangular
% window.
%
% Trials are assumed to all include the requested time span.
%
% "ftdata" is a ft_datatype_raw structure containing signal data.
% "winsize" is the window duration in seconds.
% "winstep" is the window step distance in seconds.
% "timespan" [ min max ] is the time region within which the window is to be
%   stepped.
% "freqspan" [ min max ] is the range of frequencies to evaluate.
%
% "freqlist" is a vector containing frequencies for which power was computed.
% "timelist" is a vector containing window center times that were evaluated.
% "spectpowers" is a nTrials x nChannels x nTimes x nFrequencies matrix
%   containing evaluated spectral power.


freqlist = [];
timelist = [];
spectpowers = [];


chancount = length(ftdata.label);
trialcount = length(ftdata.time);

for tidx = 1:trialcount
  thistime = ftdata.time{tidx};
  thistrial = ftdata.trial{tidx};

  for cidx = 1:chancount
    thiswave = thistrial(cidx,:);

    % NOTE - We're blithely assuming that "freqlist" and "timelist" and
    % the slice dimensions are consistent!
    % We jump through hoops in nlProc_calcSteppedWindowSpectrogram to try
    % to make that happen.

    [ freqlist timelist thisslice ] = ...
      nlProc_calcSteppedWindowSpectrogram( thistime, thiswave, ...
        winsize, winstep, timespan, freqspan );

    timecount = length(timelist);
    freqcount = length(freqlist);
    spectpowers(tidx,cidx,1:timecount,1:freqcount) = thisslice;
  end
end



% Done.
end


%
% This is the end of the file.
