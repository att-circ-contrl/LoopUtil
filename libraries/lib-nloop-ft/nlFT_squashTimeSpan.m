function newftdata = nlFT_squashTimeSpan( oldftdata, timerange )

% function newftdata = nlFT_squashTimeSpan( oldftdata, timerange )
%
% This NaNs out a specified time region within trials in Field Trip data.
%
% "oldftdata" is the Field Trip dataset to modify (ft_datatype_raw).
% "timerange" [ min max ] is the timestamp range to squash.
%
% "newftdata" is a copy of "oldftdata" with all samples in the specified
%   time range set to NaN.


newftdata = oldftdata;

trialcount = length(newftdata.time);

mintime = min(timerange);
maxtime = max(timerange);

for tidx = 1:trialcount
  thistime = newftdata.time{tidx};
  thistrial = newftdata.trial{tidx};

  thismask = (thistime >= mintime) & (thistime <= maxtime);
  thistrial(:,thismask) = NaN;

  newftdata.trial{tidx} = thistrial;
end


% Done.
end


%
% This is the end of the file.
