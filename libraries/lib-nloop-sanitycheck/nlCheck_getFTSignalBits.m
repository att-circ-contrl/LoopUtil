function chanbits = nlCheck_getFTSignalBits( ftdata )

% function chanbits = nlCheck_getFTSignalBits( ftdata )
%
% This computes the number of bits of dynamic range in each channel and trial
% in a Field Trip dataset.
%
% The number will only be meaningful with integer data (i.e. with a minimum
% step size of 1.0).
%
% This will usually be called with single-trial continuous data to provide a
% sanity check of recording settings.
%
% "ftdata" is a ft_datatype_raw structure containing ephys data.
%
% "chanbits" is a cell array with one cell per trial, each containing a
%   Nchans x 1 floating-point vector with the number of bits needed to
%   represent each channel's data in that trial.


trialcount = length(ftdata.trial);
chancount = length(ftdata.label);

chanbits = {};

for tidx = 1:trialcount
  thischanbits = zeros(chancount,1);

  for cidx = 1:chancount
    thischanbits(cidx) = nlCheck_getSignalBits( ftdata.trial{tidx}(cidx,:) );
  end

  chanbits{tidx} = thischanbits;
end


% Done.

end


%
% This is the end of the file.
