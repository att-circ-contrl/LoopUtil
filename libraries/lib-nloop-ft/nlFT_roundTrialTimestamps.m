function newftdata = nlFT_roundTrialTimestamps( oldftdata )

% function newftdata = nlFT_roundTrialTimestamps( oldftdata )
%
% This makes all timestamps in a ft_datatype_raw structure be integer
% multiples of the sampling interval.
%
% If this isn't the case, ft_timelockanalysis() can throw errors. This
% happens if data is aligned at full-rate and then downsampled.
%
% "oldftdata" is a ft_datatype_raw structure to time-align.
%
% "newftdata" is a copy of "oldftdata" with timestamps modified to be
%   integer multiples of the sampling interval.


newftdata = oldftdata;

trialcount = length(newftdata.time);

if trialcount > 0
  % FIXME - This assumes the first trial has at least 2 samples.
  % It should, but if the user tries hard enough they can cause an error here.
  samprate = 1 / median(diff( newftdata.time{1} ));

  for tidx = 1:trialcount
    thistime = newftdata.time{tidx};

    if length(thistime) > 0
      thistime = thistime * samprate;
      thisoffset = thistime(1) - round(thistime(1));
      thistime = round(thistime - thisoffset);
      thistime = thistime / samprate;
    end

    newftdata.time{tidx} = thistime;
  end
end


% Done.
end


%
% This is the end of the file.
