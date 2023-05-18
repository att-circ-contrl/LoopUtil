function newtimelock = nlFT_subtractTimelockBackground( oldtimelock, bgvec )

% function newtimelock = nlFT_subtractTimelockBackground( oldtimelock, bgvec )
%
% This subtracts a common background vector from each channel in
% oldtimelock.avg. The idea is to make local changes in response more visible.
%
% The background may be the mean (computed via nlFT_getTimelockAverage) or
% may be computed by other methods.
%
% "oldtimelock" is a dataset returned by ft_timelockanalysis.
% "bgvec" is a background vector to subtract from all channels.
%
% "newtimelock" is a copy of "oldtimelock" with the background vector
%   subtracted from newtimelock.avg.


% Implementation is vastly smaller than documentation.

newtimelock = oldtimelock;

for cidx = 1:length(newtimelock.label)
  thisslice = newtimelock.avg(cidx,:);
  newtimelock.avg(cidx,:) = thisslice - bgvec;
end


% Done.
end


%
% This is the end of the file.
