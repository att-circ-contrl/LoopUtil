function trialmask = nlFT_getNaNMask( ftdata )

% function trialmask = nlFT_getNaNMask( ftdata )
%
% This function builds a copy of a Field Trip "trial" cell array that contains
% logical matrices indicating which elements are NaN for each trial.
%
% This is intended to be used with "nlFT_fillNaN" and "nlFT_applyNaNMask".
% NaN segments are interpolated, filtering is performed, and then NaN
% segments are restored.
%
% "ftdata" is a ft_datatype_raw dataset to examine.
%
% "trialmask" is a 1xNtrials cell array containing NchansxNtime logical
%   matrices that are true for NaN elements in the original trial and false
%   otherwise.


trialmask = {};

trialcount = length(ftdata.trial);

for tidx = 1:trialcount
  trialmask{tidx} = isnan(ftdata.trial{tidx});
end


% Done.
end


%
% This is the end of the file.
