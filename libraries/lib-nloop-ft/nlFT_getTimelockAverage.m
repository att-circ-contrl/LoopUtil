function chanaverage = nlFT_getTimelockAverage( thistimelock, avgchans )

% function chanaverage = nlFT_getTimelockAverage( thistimelock, avgchans )
%
% This computes the mean response across channels in thistimelock.avg.
%
% The average is computed using a subset of the channels.
%
% "thistimelock" is a dataset returned by ft_timelockanalysis.
% "avgchans" is a cell array containing channel labels to use for building
%   the average, or {} to use all channels.
%
% "chanaverage" is the average across channels in thistimelock.avg.


chanaverage = zeros(size(thistimelock.time));


if isempty(avgchans)
  avgchans = thistimelock.label;
end

chanmask = false(size(thistimelock.label));

for cidx = 1:length(chanmask)
  thischan = thistimelock.label{cidx};
  chanmask(cidx) = ismember(thischan, avgchans);
end


if any(chanmask)

  % Build the average using only the indicated channels.

  chanaverage = zeros(size(thistimelock.time));

  for cidx = 1:length(chanmask)
    if chanmask(cidx)
      chanaverage = chanaverage + thistimelock.avg(cidx,:);
    end
  end

  chanaverage = chanaverage / sum(chanmask);

end


% Done.
end


%
% This is the end of the file.
