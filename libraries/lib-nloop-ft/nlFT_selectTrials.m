function newftdata = nlFT_selectTrials( oldftdata, trialmask )

% function newftdata = nlFT_selectTrials( oldftdata, trialmask )
%
% This keeps only the specified subset of trials in a Field Trip data
% structure, adjusting structure fields appropriately.
%
% NOTE - Field Trip will complain vigorously if you give it a data structure
% with no trials! Only call this if at least one trial will be kept.
%
% "oldftdata" is the Field Trip data structure to modify.
% "trialmask" is a logical vector with one entry per trial, which is true
%   for the trials to be kept and false for the trials to discard.
%
% "newftdata" is a copy of "oldftdata" containing only the desired trials.


newftdata = oldftdata;


% Make copies with forced geometry.

trialmaskrow = trialmask;
trialmaskcol = trialmask;
if isrow(trialmask)
  trialmaskcol = transpose(trialmaskcol);
else
  trialmaskrow = transpose(trialmaskrow);
end


% Do the filtering.

% "time" and "trial" are 1 x Ntrials, "sampleinfo" and "trialinfo" are
% Ntrials x K. Check for "trl" and "trialdef", too (also Ntrials x K).

newftdata.time = newftdata.time(trialmaskrow);
newftdata.trial = newftdata.trial(trialmaskrow);

if isfield(newftdata, 'sampleinfo')
  newftdata.sampleinfo = oldftdata.sampleinfo(trialmaskcol,:);
end
if isfield(newftdata, 'trialinfo')
  newftdata.trialinfo = oldftdata.trialinfo(trialmaskcol,:);
end
if isfield(newftdata, 'trl')
  newftdata.trl = oldftdata.trl(trialmaskcol,:);
end
if isfield(newftdata, 'trialdef')
  newftdata.trialdef = oldftdata.trialdef(trialmaskcol,:);
end



% Done.
end


%
% This is the end of the file.
