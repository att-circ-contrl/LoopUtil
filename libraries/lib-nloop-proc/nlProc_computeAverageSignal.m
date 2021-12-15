function avgseries = ...
  nlProc_computeAverageSignal(metadata, chanlist, memchans, preprocfunc)

% function avgseries = ...
%   nlProc_computeAverageSignal(metadata, chanlist, memchans, preprocfunc)
%
% This iterates through a list of channels, computing the average signal
% value of all specified channels. The average signal is returned.
%
% NOTE - It is the user's responsibility to ensure that all listed channels
% are time-aligned and have data values that use the same scale. If all
% signals are from the same ephys machine, that's usually handled. Otherwise
% the preprocessing function should handle that.
%
% "metadata" is the project metadata structure, per FOLDERMETA.txt.
% "chanlist" is a structure listing the channels to be averaged, per
%   CHANLIST.txt.
% "memchans" is the maximum number of channels that may be loaded into
%   memory at the same time.
% "preprocfunc" is a function handle that is called to preprocess each
%   channel's data prior to being averaged, per PROCFUNC.txt. This typically
%   performs artifact removal (filtering happens after re-referencing).
%
% "avgseries" is a data series computed as the average of the input channels.
%   Input series of different lengths are tolerated, but all are assumed to
%   start at the same time and to have the same sampling rate.


% FIXME - Define global variables to hold sums and counts.
% This forces us to evaluate the loop sequentially rather than in parallel!

global nlProc_computeAverageSignal_Totals;
global nlProc_computeAverageSignal_Counts;


% Define a processing function that preprocesses a signal and adds it to
% these counts.

tallyfunc = @(metadata, folderid, bankid, chanid, ...
  wavedata, timedata, wavenative, timenative) ...
  helper_addToTally(metadata, folderid, bankid, chanid, ...
    wavedata, timedata, wavenative, timenative, preprocfunc);


% Iterate through the specified channels.

resultvals = nlIO_iterateChannels(metadata, chanlist, memchans, tallyfunc);


% We can ignore the result value; the global tally update is what we want.
% If the output is non-empty, we have at least one count for every sample.
avgseries = nlProc_computeAverageSignal_Totals;
if ~isempty(avgseries)
  avgseries = avgseries ./ nlProc_computeAverageSignal_Counts;
end


% Done.

end


%
% Helper Functions


function returnval = helper_addToTally( ...
  metadata, folderid, bankid, chanid, ...
  wavedata, timedata, wavenative, timenative, tallypreprocfunc )

  % Return a dummy value; the iterator needs this.
  returnval = 1;

  % Get access to the global tallies.
  global nlProc_computeAverageSignal_Totals;
  global nlProc_computeAverageSignal_Counts;

  % Preprocess this data.
  cookedsignal = tallypreprocfunc( metadata, folderid, bankid, chanid, ...
    wavedata, timedata, wavenative, timenative );

  % If we're the first signal to be processed, initialize the tallies.
  % Otherwise expand if necessary, and add this signal.

  if isempty(cookedsignal)
    % We have no data. Do nothing.
  elseif isempty(nlProc_computeAverageSignal_Totals)
    % We have no tally. Initialize it.
    nlProc_computeAverageSignal_Totals = cookedsignal;
    nlProc_computeAverageSignal_Counts = ones(size(cookedsignal));
  else
    % We have a pre-existing tally.

    % Make sure the tally is at least as big as the input.
    tallysize = length(nlProc_computeAverageSignal_Totals);
    signalsize = length(cookedsignal);
    if tallysize < signalsize
      nlProc_computeAverageSignal_Totals((1+tallysize):signalsize) = 0;
      nlProc_computeAverageSignal_Counts((1+tallysize):signalsize) = 0;
    end

    % Add this input.
    nlProc_computeAverageSignal_Totals(1:signalsize) = ...
      nlProc_computeAverageSignal_Totals(1:signalsize) + cookedsignal;
    nlProc_computeAverageSignal_Counts(1:signalsize) = ...
      nlProc_computeAverageSignal_Counts(1:signalsize) + 1;
  end

end


%
% This is the end of the file.
