function [ newtrials auxdata ] = nlFT_iterateAcrossData( ftdata, iterfunc )

% function [ newtrials auxdata ] = nlFT_iterateAcrossData( ftdata, iterfunc )
%
% This iterates across the trials and channels in a Field Trip dataset,
% applying a processing function to each trial and channel's data. Processing
% output is aggregated and returned.
%
% "ftdata" is an "ft_datatype_raw" data structure.
% "iterfunc" is a function handle used to transform channel waveform data
%   into "result" data, per FT_ITERFUNC.txt.
%
% "newtrials" is a processed copy of the "trial" field, containing modified
%   per-trial and per-channel waveform data.
% "auxdata" is a cell array indexed by {trial,channel} containing auxiliary
%   data returned by the iteration processing function.


newtrials = {};
auxdata = {};


samprate = ftdata.fsample;
chancount = length(ftdata.label);
trialcount = length(ftdata.time);

for tidx = 1:trialcount
  thistime = ftdata.time{tidx};
  thistrialdata = ftdata.trial{tidx};
  newdata = [];

  for cidx = 1:chancount
    thisdata = thistrialdata(cidx,:);

    [ newwave newaux ] = iterfunc( ...
      thisdata, thistime, samprate, tidx, cidx, ftdata.label{cidx} );

    newdata(cidx,:) = newwave;
    auxdata{tidx,cidx} = newaux;
  end

  newtrials{tidx} = newdata;
end


% Done.

end


%
% This is the end of the file.
