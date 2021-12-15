function [ newdata fracbad ] = nlChan_applyArtifactReject( ...
  wavedata, refdata, samprate, tuningparams, keepnan )

% function [ newdata fracbad ] = nlChan_applyArtifactReject( ...
%   wavedata, samprate, tuningparams, keepnan )
%
% This performs truncation and artifact rejection, optionally followed by
% interpolation in the former artifact regions.
%
% "wavedata" is the waveform to process.
% "refdata" is a reference to subtract from the waveform, or [] for no
%   reference. The reference should already be truncated and have artifacts
%   removed, but should retain NaN values to avoid introducing new artifacts.
% "samprate" is the sampling rate.
% "tuningparams" is a structure containing tuning parameters for artifact
%   rejection.
% "keepnan" is true if NaN values are to remain and false if interpolation
%   is to be performed to remove them.
%
% "newdata" is the series after artifact removal.
% "fracbad" is the fraction of samples discarded as artifacts (0..1).


% Work with a consistent variable.
newdata = wavedata;


%
% Trim the waveform.

if (0 < tuningparams.trimstart) || (0 < tuningparams.trimend)
  newdata = nlProc_trimEndpointsTime( newdata, samprate, ...
    tuningparams.trimstart, tuningparams.trimend );
end


%
% Perform artifact rejection.

% Use "timehalosecs" for both the leading and following intervals.

newdata = nlProc_removeArtifactsSigma( newdata, ...
  tuningparams.ampthresh, tuningparams.diffthresh, ...
  tuningparams.amphalo, tuningparams.diffhalo, ...
  round(tuningparams.timehalosecs * samprate), ...
  round(tuningparams.timehalosecs * samprate), ...
  round(tuningparams.smoothsecs * samprate), ...
  round(tuningparams.dcsecs * samprate) );

artsamps = sum(isnan(newdata));
sampcount = length(newdata);
fracbad = artsamps / sampcount;


%
% Subtract the reference.

% This gives us output that has NaN where _either_ of the input waves had
% artifacts.

if (0 < length(refdata))
  newdata = newdata - refdata;
end


%
% Perform interpolation.

% NOTE - this doesn't accept tuning parameters.

if ~keepnan
  newdata = nlProc_fillNaN(newdata);
end


%
% Done.

end


%
% This is the end of the file.
