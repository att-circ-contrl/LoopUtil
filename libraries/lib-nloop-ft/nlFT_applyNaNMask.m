function newftdata = nlFT_applyNaNMask( oldftdata, trialmask )

% function newftdata = nlFT_applyNaNMask( oldftdata, trialmask )
%
% This function NaNs out samples in Field Trip trials following the pattern
% recorded in "trialmask".
%
% This is intended to be used with "nlFT_getNaNMask" and "nlFT_fillNaN".
% NaN segments are interpolated, filtering is performed, and then NaN
% segments are restored.
%
% "oldftdata" is a ft_datatype_raw dataset to modify.
% "trialmask" is a cell array with NaN masks, per nlFT_getNaNMask().
%
% "newftdata" is a copy of "oldftdata" with indicated samples set to NaN.


newftdata = oldftdata;

trialcount = length(trialmask);

for tidx = 1:trialcount
  thistrial = newftdata.trial{tidx};
  thismask = trialmask{tidx};

  thistrial(thismask) = NaN;

  newftdata.trial{tidx} = thistrial;
end


% Done.
end


%
% This is the end of the file.
