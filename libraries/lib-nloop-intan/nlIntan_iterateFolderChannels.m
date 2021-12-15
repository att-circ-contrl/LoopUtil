function folderresults = nlIntan_iterateFolderChannels( ...
  foldermetadata, folderchanlist, memchans, procfunc, procmeta, procfid )

% function folderresults = nlIntan_iterateFolderChannels( ...
%   foldermetadata, folderchanlist, memchans, procfunc, procmeta, procfid )
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
%   into "result" data, per PROCFUNC.txt.
% "procmeta" is the object to pass as the "metadata" argument of "procfunc".
% "procfid" is the  label to pass as the "folderid" argument of "procfunc".
%
% "folderresults" is a folder-level channel list structure that has
%   bank-level channel lists augmented with a "resultlist" field, per
%   CHANLIST.txt. The "resultlist" field is a cell array containing
%   per-channel output from "procfunc".


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

    thissigtype = thisbankmeta.banktype;
    thiszerolevel = thisbankmeta.nativezerolevel;
    thisscale = thisbankmeta.nativescale;

    thishandle = thisbankmeta.handle;
    thisformat = thishandle.format;
    thisspecial = thishandle.special;


    % How we iterate this depends on how it's stored.
    if strcmp(thisformat, 'onefileperchan')

      % FIXME - Single-threaded implementation!
      % Process these channels one at a time; there's no benefit to reading
      % multiple files into memory without parallelization.

      chanfilechans = thishandle.chanfilechans;
      chanfilenames = thishandle.chanfilenames;

      timefile = thishandle.timefile;
      [ is_ok timenative ] = ...
        nlIO_readBinaryFile( timefile, thisbankmeta.nativetimetype );
      if ~is_ok
        disp(sprintf( '###  Unable to read from "%s".', timefile ));
      else
        % Convert time to cooked format from native format.
        timecooked = double(timenative) / thisbankmeta.samprate;

        % Iterate requested channels, reading and processing the ones
        % that exist. Silently ignore ones that don't exist.

        foundcount = 0;
        for cidx = 1:length(thisbankchans)
          thischan = thisbankchans(cidx);
          % This has 0 entries if no match, or one entry per match.
          thisfname = chanfilenames(chanfilechans == thischan);
          if ~isempty(thisfname)

            thisfname = thisfname{1};
            [ is_ok datanative ] = ...
              nlIO_readBinaryFile( thisfname, thisbankmeta.nativedatatype );
            if ~is_ok
              disp(sprintf( '###  Unable to read from "%s".', thisfname ));
            else

              % We've just read in an array of int16 or uint16.
              % How we process this depends on what our type is and on
              % whether we have a special case to handle.


              % First, handle special case preprocessing.
              % Both of these are for stimulation current (encoded uint16).

              if strcmp('stimcurrent', thisspecial)
                % Manually decode 9-bit signed non-complement values to int16.
                % Remember that Matlab calls the LSB bit 1, not bit 0.
                wantnegative = (bitget(datanative, 9) > 0);
                datanative = int16(bitand(datanative,0x00ff));
                datanative(wantnegative) = -datanative(wantnegative);
              elseif strcmp('stimflags', thisspecial)
                % Mask off the 9-bit signed value, keeping the flag bits.
                datanative = bitand(datanative, 0xfe00);
              end


              % Next, make the cooked values.

              % Assign a (bogus) default value.
              datacooked = zeros(size(datanative));

              if strcmp('boolean', thissigtype)
                % Convert to boolean (logical) values.
                datacooked = (datanative > 0.5);
              elseif strcmp('flagvector', thissigtype)
                % Convert to double but don't modify.
                datacooked = double(datanative);
              else
                % Convert to double and apply offset and scaling.
                datacooked = double(datanative);
                datacooked = (datacooked - thisbankmeta.nativezerolevel) ...
                  * thisbankmeta.nativescale;
              end

              thisresult = ...
                procfunc( procmeta, procfid, thisbanklabel, thischan, ...
                  datacooked, timecooked, datanative, timenative );

              % Store this result.
              foundcount = foundcount + 1;
              chanfoundlist(foundcount) = thischan;
              chanresultlist{foundcount} = thisresult;
            end

          end
        end

      end

    else
      % FIXME - "neuroscope" and "monolithic" file types NYI.
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
