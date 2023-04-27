function newftdata = nlFT_applyTimeWindowSquash( oldftdata, timemasks )

% function newftdata = nlFT_applyTimeWindowSquash( oldftdata, timemasks )
%
% This NaNs out the indicated time regions in every trial within a Field
% Trip dataset.
%
% This is intended to be used with nlFT_getWindowsAroundEvents for artifact
% rejection.
%
% "oldftdata" is a ft_datatype_raw dataset to modify.
% "timemasks" is a 1xNtrials cell array. Each cell contains a 1xNsamples
%   logical vector that's true on every sample to be squashed.
%
% "newftdata" is a copy of "oldftdata" with the indicated samples set to NaN.


newftdata = oldftdata;

trialcount = length(timemasks);

for tidx = 1:trialcount
  thistrial = newftdata.trial{tidx};
  thismask = timemasks{tidx};

  thistrial(:,thismask) = NaN;

  newftdata.trial{tidx} = thistrial;
end


% Done.
end


%
% This is the end of the file.
