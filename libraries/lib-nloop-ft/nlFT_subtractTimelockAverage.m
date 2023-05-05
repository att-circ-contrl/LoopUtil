function newtimelock = ...
  nlFT_subtractTimelockAverage( oldtimelock, avgchans )

% function newtimelock = ...
%   nlFT_subtractTimelockAverage( oldtimelock, avgchans )
%
% This subtracts the average response across channels from each channel in
% oldtimelock.avg. The idea is to make local changes in response more visible.
%
% "oldtimelock" is a dataset returned by ft_timelockanalysis.
% "avgchans" is a cell array containing channel labels to use for building
%   the average, or {} to use all channels.
%
% "newtimelock" is a copy of "oldtimelock" with the average across channels
%   in oldtimelock.avg subtracted from newtimelock.avg.


newtimelock = oldtimelock;


if isempty(avgchans)
  avgchans = newtimelock.label;
end

chanmask = false(size(newtimelock.label));

for cidx = 1:length(chanmask)
  thischan = newtimelock.label{cidx};
  chanmask(cidx) = ismember(thischan, avgchans);
end


if any(chanmask)

  avgtotal = zeros(size(newtimelock.time));

  for cidx = 1:length(chanmask)
    if chanmask(cidx)
      avgtotal = avgtotal + newtimelock.avg(cidx,:);
    end
  end

  avgtotal = avgtotal / sum(chanmask);

  for cidx = 1:length(chanmask)
    if chanmask(cidx)
      thisslice = newtimelock.avg(cidx,:);
      newtimelock.avg(cidx,:) = thisslice - avgtotal;
    end
  end

end


% Done.
end


%
% This is the end of the file.
