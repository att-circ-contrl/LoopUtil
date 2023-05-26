function newftdata = nlFT_fillNaN( oldftdata )

% function newftdata = nlFT_fillNaN( oldftdata )
%
% This calls nlProc_fillNaN() to interpolate NaN segments within all trials
% of the supplied Field Trip dataset.
%
% "oldftdata" is a ft_datatype_raw dataset to modify.
%
% "newftdata" is a copy of "oldftdata" with NaN segments interpolated.


trialcount = length(oldftdata.trial);
chancount = length(oldftdata.label);

newftdata = oldftdata;

for tidx = 1:trialcount
  thistrial = newftdata.trial{tidx};
  newftdata.trial{tidx} = nlProc_fillNaNRows(thistrial);
end


% Done.
end


%
% This is the end of the file.
