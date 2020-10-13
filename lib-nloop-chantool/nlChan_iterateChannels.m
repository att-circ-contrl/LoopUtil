function outdata = ...
  nlChan_iterateChannels(chanfiles, bankrefs, samprate, tuningart, procfunc)

% function outdata = ...
%   nlChan_iterateChannels(chanfiles, bankrefs, samprate, refparams, procfunc)
%
% This iterates through a list of channel records, loading and preprocessing
% each channel and then calling a processing function with the channel
% data. Processing output is aggregated and returned.
%
% "chanfiles" is an array of channel file records in the format returned by
%   nlIntan_probeAmpChannels(). These have the following fields:
%   "bank" - Amplifier identifier string.
%   "chan" - Channel number.
%   "fname" - Name of the file containing this bank/channel's data.
% "bankrefs" is a structure with field names that are bank identifiers, with
%   each field containing a single channel number specifying the in-bank
%   channel to use as a reference for the remaining channels. If an empty
%   array is present or if a bank identifier is absent, no reference is used
%   for that bank. These channels must also be present in "chanfiles".
% "samprate" is the sampling rate.
% "tuningart" is a structure containing tuning parameters for artifact
%   rejection.
% "procfunc" is a function handle that is called per file. It has the form:
%     resultval = procfunc(chanrec, wavedata)
%   This is typically an anonymous function that wraps a function with
%   additional arguments.
%
% "outdata" is a copy of "chanfiles" augmented with an additional "result"
%   field, containing "resultval" returned from procfunc(). Only records
%   corresponding to channels that were processed are present; channels that
%   were discarded due to artifacts or that were references are absent.


reffile = 'bogus';
refdata = [];

outcount = 0;

for fidx = 1:length(chanfiles)

  thisrec = chanfiles(fidx);

  % FIXME - Diagnostics.
  disp(sprintf('-- Reading "%s"...', thisrec.fname));

  [ is_ok thisdata ] = nlUtil_readBinaryFile(thisrec.fname, 'int16');


  % If we have a reference, read it.
  % Keep the old one if it's the same file, rather than re-reading and
  % processing the reference for every input file.

  if is_ok
    if isfield(bankrefs, thisrec.bank)
      thisrefchan = bankrefs.(thisrec.bank);

      if (0 < length(thisrefchan))
        thisrefchan = thisrefchan(1);
        thisref = helper_lookUpFilename(chanfiles, thisrec.bank, thisrefchan);

        if (0 < length(thisref)) && (~strcmp(thisref, reffile))
          reffile = thisref;
          if isfile(reffile)

            [ is_ok refdata ] = nlUtil_readBinaryFile(reffile, 'int16');

            if is_ok
              % Artifact rejection also handles trimming.
              % Keep NaN values intact in the reference waveform.
              [ refdata fracbad ] = nlChan_applyArtifactReject( ...
                  refdata, [], samprate, tuningart, true );
            else
              refdata = [];
            end
          else
            refdata = [];
          end
        end
      else
        refdata = [];
      end
    end
  end


  % Process this signal.

  if is_ok
    if strcmp(reffile, thisrec.fname)
      % FIXME - Diagnostics.
      disp('.. This is the reference waveform.');
    else

      % FIXME - Diagnostics / progress banner.
%      disp(sprintf( '.. Bank %s chan %2d filename "%s"...', ...
%        thisrec.bank, thisrec.chan, thisrec.fname ));

      % Artifact rejection also handles trimming.
      [ thisdata fracbad ] = nlChan_applyArtifactReject( ...
        thisdata, refdata, samprate, tuningart, false );

      if 0.1 < fracbad
        % FIXME - Diagnostics.
        disp(sprintf( '== Rejecting bank %s channel %03d (%.1f %% bad).', ...
          thisrec.bank, thisrec.chan, 100 * fracbad ));
      else
        % FIXME - Diagnostics.
%        disp(sprintf( 'Bad: %.1f %%', 100 * fracbad ));

        % Wrap the user-supplied function.

        thisrec.result = procfunc( thisrec, thisdata );
        outcount = outcount + 1;
        outdata(outcount) = thisrec;
      end

    end
  end


  % Finished with this channel.

end



%
% Done.

end


%
% Private helper functions.


% This looks up the filename for a bank/channel combination.
% It returns '' if no filename record is found.

function fname = helper_lookUpFilename(chanfiles, bankid, channum)

  fname = '';

  for fidx = 1:length(chanfiles)
    thisrec = chanfiles(fidx);
    if (bankid == thisrec.bank) && (channum == thisrec.chan)
      fname = thisrec.fname;
    end
  end

end


%
% This is the end of the file.
