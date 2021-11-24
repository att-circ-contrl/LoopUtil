function folderresults = nlIntan_iterateFolderChannels( ...
  foldermetadata, folderchanlist, memchans, procfunc )

% function folderresults = nlIntan_iterateFolderChannels( ...
%   foldermetadata, folderchanlist, memchans, procfunc )
%
% This processes a folder containing Intan-format data, iterating through
% a list of channels, loading each channel's waveform data in sequence and
% calling a processing function with that data. Processing output is
% aggregated and returned.
%
% This is implemented such that only a few channels are loaded at a time.
%
% Channel time series are stored as sample numbers (not times). Analog data
% is converted to microvolts. TTL data is converted to boolean.
%
% "foldermetadata" is a folder-level metadata structure, per FOLDERMETA.txt.
% "folderchanlist" is a structure listing channels to process; it is a
%   folder-level channel list per CHANLIST.txt.
% "memchans" is the maximum number of channels that may be loaded into
%   memory at the same time.
% "procfunc" is a function handle used to transform channel waveform data
%   into "result" data, per PROCFUNC.txt. NOTE - "metadata" and "folderid"
%   arguments are not passed to this function; the caller should handle that
%   via an anonymous wrapper.
%
% "resultvals" is a folder-level channel list structure that has bank-level
%   channel lists augmented with a "resultlist" field, per CHANLIST.txt.
%   The "resultlist" field is a cell array containing per-channel output
%   from "procfunc".


% Initialize output.
folderresults = struct();


% Iterate through the requested bank list.

banklist = fieldnames(folderchanlist);
for bidx = 1:length(banklist)

  % Make sure this folder actually exists before processing it.
  thisbanklabel = banklist{bidx};

  if isfield(foldermetadata.banks, thisbanklabel)
    % Initialize output.
    chanfoundlist = [];
    chanresultlist = {};

    % Look up appropriate metadata.
    thisbankmeta = foldermetadata.banks.(thisbanklabel);
    thisbankchans = folderchanlist.(thisbanklabel).chanlist;

    thisdtype = thisbankmeta.banktype;
    thishandle = thisbankmeta.handle;

    thisformat = thishandle.format;

    % How we iterate this depends on how it's stored.
    if strcmp(thisformat, 'onefileperchan')

      % FIXME - Single-threaded implementation!
      % Process these channels one at a time; there's no benefit to reading
      % multiple files into memory without parallelization.

      chanfilechans = thishandle.chanfilechans;
      chanfilenames = thishandle.chanfilenames;

      timefile = thishandle.timefile;
      [ is_ok timedata ] = nlIO_readBinaryFile( timefile, 'int32' );
      if ~is_ok
        disp(sprintf( '###  Unable to read from "%s".', timefile ));
      else
        % Iterate requested channels, reading and processing the ones
        % that exist. Silently ignore ones that don't exist.

        foundcount = 0;
        for cidx = 1:length(thisbankchans)
          thischan = thisbankchans(cidx);
          % This has 0 entries if no match, or one entry per match.
          thisfname = chanfilenames(chanfilechans == thischan);
          if ~isempty(thisfname)

            thisfname = thisfname{1};
            [ is_ok wavedata ] = nlIO_readBinaryFile( thisfname, 'int16' );
            if ~is_ok
              disp(sprintf( '###  Unable to read from "%s".', thisfname ));
            else
              % The input samples for this format are always int16, even
              % for TTL data.
              if strcmp('analog', thisbankmeta.banktype)
                % Convert to microvolts, using Intan's fixed scale factor.
                wavedata = wavedata * 0.195;
              elseif strcmp('ttl', thisbankmeta.banktype)
                % Convert to boolean (logical) values.
                wavedata = (wavedata > 0.5);
              else
                % This signal has an unknown data type.
                % FIXME - Silently leave the signal data as we found it.
              end

              % NOTE - The caller handles passing "metadata" and "folderid".
              thisresult = ...
                procfunc(thisbanklabel, thischan, wavedata, timedata );

              % Store this result.
              foundcount = foundcount + 1;
              chanfoundlist(foundcount) = thischan;
              chanresultlist{foundcount} = thisresult;
            end

          end
        end

      end

    else
      % FIXME - "neuroscope" and "monolithic" file types not yet supported.
      % For both of these, we'll want to batch channels and read them N at
      % a time rather than one at a time, to avoid making repeated passes
      % through the file.

      % FIXME - Diagnostics.
      disp(sprintf( '###  Not sure how to iterate a "%s" folder.', ...
        thisdevice ));
    end

    % Store this bank's results.
    % Remember to wrap cell arrays.
    folderresults.(thisbanklabel) = ...
      struct( 'chanlist', chanfoundlist, 'resultlist', { chanresultlist } );
  end

end




% Done.

end


%
% This is the end of the file.
