function newtimelock = ...
  nlFT_subtractTimelockAverage( oldtimelock, avgchans )

% function newtimelock = ...
%   nlFT_subtractTimelockAverage( oldtimelock, avgchans )
%
% This subtracts the average response across channels from each channel in
% oldtimelock.avg. The idea is to make local changes in response more visible.
%
% The average is computed using a subset of the channels, but subtracted from
% all channels.
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

  % Build the average using only the indicated channels.

  avgtotal = zeros(size(newtimelock.time));

  for cidx = 1:length(chanmask)
    if chanmask(cidx)
      avgtotal = avgtotal + newtimelock.avg(cidx,:);
    end
  end

  avgtotal = avgtotal / sum(chanmask);


  % Subtract the average from all channels.

  for cidx = 1:length(chanmask)
    thisslice = newtimelock.avg(cidx,:);
    newtimelock.avg(cidx,:) = thisslice - avgtotal;
  end

end


% Done.
end


%
% This is the end of the file.
