function [ ftdata auxdata ] = nlFT_iterateAcrossFolderBatching( ...
  config_load, iterfunc_batched, chanbatchsize, trialbatchsize, verbosity )

% function auxdata = nlFT_iterateAcrossFolderBatching( ...
%   config_load, iterfunc_batched, chanbatchsize, trialbatchsize, verbosity )
%
% This iterates across a Field Trip dataset, loading a few channels at a
% time and/or a few trials at a time and applying a processing function to
% each channel subset. Processing output is aggregated and returned.
%
% The idea is to be able to process a dataset much larger than can fit in
% memory. At 30 ksps the footprint is typically about 1 GB per channel-hour.
%
% This calls an iteration function handle of the type described by
% FT_ITERFUNC_BATCHED.txt.
%
% NOTE - If the iteration function returns anything for "ftdata_new", make
% sure the aggregated result is small enough to fit in memory!
%
% "config_load" is a Field Trip configuration structure to be passed to
%   ft_preprocessing() to load the data. The "channel" field is split into
%   batches when iterating.
% "iterfunc_batched" is a function handle used to transform channel waveform
%   data into "result" data, per FT_ITERFUNC_BATCHED.txt.
% "chanbatchsize" is the number of channels to process at a time. Set this to
%   inf to process all channels at once.
% "trialbatchsize" is the number of trials to process at a time. Set this to
%   inf to process all trials at once.
% "verbosity" is an optional argument. It can be set to 'none' (no console
%   output), 'terse' (reporting the number of channels processed), or 'full'
%   (reporting the names of channels processed). The default is 'none'.
%
% "ftdata" is a "ft_datatype_raw" structure built by aggregating the Field
%   Trip data structures ("ftdata_new") returned by the iteration processing
%   function. These are assumed to be compatible (same sampling rate, etc),
%   and the aggregated result must fit in memory. If the iteration function
%   returns struct([]) as ftdata_new, "ftdata" is also set to struct([]).
% "auxdata" is a cell array indexed by {trial,channel} containing the
%   auxiliary data ("auxdata") returned by the iteration processing
%   function.


if ~exist('verbosity', 'var')
  verbosity = 'none';
end


ftdata = struct([]);
auxdata = {};

any_were_empty = false;


chanlist_full = config_load.channel;
chancount = length(chanlist_full);

trialdefs_full = config_load.trl;
trialcount = size(trialdefs_full);  % Nx3 matrix.
trialcount = trialcount(1);


% Iterate trials.

for trialbidx = 1:trialbatchsize:trialcount

  % Define this batch of trials.

  tidxend = trialbidx + trialbatchsize - 1;
  tidxend = min(tidxend, trialcount);

  thistriallist = trialdefs_full(trialbidx:tidxend,:);
  config_load.trl = thistriallist;


  % Progress report.

  if ~strcmp(verbosity, 'none')
    disp(sprintf( '.. Processing trials %d - %d of %d...', ...
      trialbidx, tidxend, trialcount ));
  end


  % Iterate channels.

  for chanbidx = 1:chanbatchsize:chancount

    % Define this batch of channels.

    cidxend = chanbidx + chanbatchsize - 1;
    cidxend = min(cidxend, chancount);

    thischanlist = chanlist_full(chanbidx:cidxend);
    config_load.channel = thischanlist;


    % Progress report.

    if ~strcmp(verbosity, 'none')
      disp(sprintf( '.. Processing channels %d - %d of %d...', ...
        chanbidx, cidxend, chancount ));

      if strcmp(verbosity, 'full')
        scratch = '(';
        for cidx = chanbidx:cidxend
          % Reporting raw names, since we don't have access to cooked.
          scratch = [ scratch ' ' chanlist_full{cidx} ' ' ];
        end
        scratch = [ scratch ')' ];
        disp(scratch);
      end
    end


    % Process this batch.

    thisdata = ft_preprocessing( config_load );
    [ newdata thisaux ] =  ...
      iterfunc_batched( thisdata, thischanlist, thistriallist );

    auxdata(trialbidx:tidxend,chanbidx:cidxend) = thisaux;

    if isempty(newdata)

      any_were_empty = true;
      ftdata = struct([]);

    elseif ~any_were_empty

      if isempty(ftdata)
        % This should contain the first batch of trials and channels,
        % which we'll append to afterwards.
        ftdata = newdata;
      else
        % We're appending to an existing dataset.
        % Overwriting per-trial and per-channel info is fine.

        ftdata.label(chanbidx:cidxend) = newdata.label;
        ftdata.time(trialbidx:tidxend) = newdata.time;

        if isfield(newdata, 'sampleinfo')
          ftdata.sampleinfo(trialbidx:tidxend,:) = newdata.sampleinfo;
        end

        if isfield(newdata, 'trialinfo')
          ftdata.trialinfo(trialbidx:tidxend,:) = newdata.trialinfo;
        end

        if chanbidx <= 1
          % First batch of channels for this trial; we haven't seen these
          % trials yet.
          ftdata.trial(trialbidx:tidxend) = newdata.trial;
        else
          % Appending channel data to existing trials.
          for oldtidx = trialbidx:tidxend
            newtidx = oldtidx + 1 - trialbidx;
            scratchold = ftdata.trial{oldtidx};
            scratchnew = newdata.trial{newtidx};
            scratchold(chanbidx:cidxend,:) = scratchnew;
            ftdata.trial{oldtidx} = scratchold;
          end
        end

      end

    end

  end
end


% Done.
end


%
% This is the end of the file.
