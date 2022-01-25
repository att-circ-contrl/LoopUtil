function header = nlFT_readHeader(indir)

% function header = nlFT_readHeader(indir)
%
% This probes the specified directory using nlIO_readFolderMetadata(),
% and translates the folder's metadata into a Field Trip header.
%
% This is intended to be called by ft_read_header() via the "headerformat"
% argument.
%
% This calls nlFT_testWantChannel() and nlFT_testWantBank() and only saves
% channels that are wanted. By default all channels and banks are wanted;
% use nlFT_selectChannels() to change this.
%
% NOTE - The following nonstandard fields are added to the header. All of
% these are cell arrays with per-channel metadata copied from the LoopUtil
% bank metadata (per FOLDERMETA.txt).
%   "channativezero" is the native data value representing a signal value of
%     zero.
%   "channativescale" is a multiplier used to convert "native" data values to
%     double-precision floating-point data values in appropriate units.
%   "chanflagbits" is a structure indexed by flag label containing the
%     integer bit-mask values that correspond to each flag, for "flagvector"
%     data. This is an empty structure for other data.
%
% If probing fails, an error is thrown.
%
% "indir" is the directory to process.
%
% "header" is the resulting Field Trip header.


[ isok foldermeta ] = nlIO_readFolderMetadata( ...
  struct([]), 'datafolder', indir, 'auto' );

if ~isok
  error(sprintf( ...
    'nlIO_readFolderMetadata() didn''t find anything in "%s".', indir ));
else
  % We only care about this particular folder's metadata.
  bankmeta = foldermeta.folders.('datafolder').banks;


  % Initialize header data.

  samprate = NaN;
  sampcount = NaN;
  chancount = 0;

  channames = {};
  chantypes = {};
  chanunits = {};

  % NOTE - Custom metadata.
  channativezero = {};
  channativescale = {};
  chanflagbits = {};


  % Iterate through banks.
  % NOTE - Do this in sorted order for consistent numbering.

  banknames = sort( fieldnames(bankmeta) );


  % Main iteration.

  for bidx = 1:length(banknames)
    thisbankname = banknames{bidx};
    thisbankmeta = bankmeta.(thisbankname);

    thischanlist = thisbankmeta.channels;
    thisrate = thisbankmeta.samprate;
    thiscount = thisbankmeta.sampcount;
    thistype = thisbankmeta.banktype;
    thisunit = thisbankmeta.fpunits;

    % Additional metadata to be stored.
    thisnativezero = thisbankmeta.nativezerolevel;
    thisnativescale = thisbankmeta.nativescale;
    thisflagbits = struct([]);
    if isfield(thisbankmeta, 'flagdefs')
      thisflagbits = thisbankmeta.flagdefs;
    end

    % First, see if this is a bank we want to process at all.

    if nlFT_testWantBank(thisbankname, thistype) ...

      % NOTE - Sparse (event) banks already report non-sparse sample count.
      % There's no need to special-case here now.

      % Second, see if this bank's sampling rate and length are consistent
      % with any other banks we've processed so far.

      if isnan(samprate)
        samprate = thisrate;
      end
      if isnan(sampcount)
        sampcount = thiscount;
      end

      % FIXME - Field Trip only understands files where all banks have the
      % same sampling rate and the same sample count. So, bail out with an
      % error if that's not the case.

      if thisrate ~= samprate
        isok = false;
        error(sprintf( [ 'Bank "%s" has sampling rate %d, while previous ' ...
          'banks had rate %d. Field Trip doesn''t like this.' ], ...
          thisbankname, thisrate, samprate ));
      elseif thiscount ~= sampcount
        isok = false;
        error(sprintf( [ 'Bank "%s" has %d samples, while previous ' ...
          'banks had %d samples. Field Trip doesn''t like this.' ], ...
          thisbankname, thiscount, sampcount ));
      else

        % This bank has the expected rate and lenth, and passes filtering.

        % Build and filter the list of prospective channel names.

        newchannames = {};
        newchanqty = 0;

        for cidx = 1:length(thischanlist)
          thischanname = nlFT_makeFTName( thisbankname, thischanlist(cidx) );

          if nlFT_testWantChannel(thischanname)
            newchanqty = newchanqty + 1;
            newchannames{newchanqty} = thischanname;
          end
        end

        % If we have any channels left, add this bank's channels.

        if length(newchannames) > 0
          newchanqty = length(newchannames);

          channames( (chancount+1):(chancount+newchanqty) ) = newchannames;
          chantypes( (chancount+1):(chancount+newchanqty) ) = { thistype };
          chanunits( (chancount+1):(chancount+newchanqty) ) = { thisunit };

          % NOTE - Custom metadata.
          % FIXME - Force this to be Nchans*1, like the other metadata.
          channativezero( (chancount+1):(chancount+newchanqty), 1 ) = ...
            { thisnativezero };
          channativescale( (chancount+1):(chancount+newchanqty), 1 ) = ...
            { thisnativescale };
          chanflagbits( (chancount+1):(chancount+newchanqty), 1 ) = ...
            { thisflagbits };

          chancount = chancount + newchanqty;
        end

      end

    end
  end


  % Construct the FT header.

  header = struct([]);

  if isok
    % Fill in bogus values if we had no channels.
    if isnan(samprate)
      samprate = 0;
    end
    if isnan(sampcount)
      sampcount = 0;
    end

    % Construct the header.
    % NOTE - Adding some of the LoopUtil metadata here as extra fields.
    % We'll need it for native data conversion and for decoding flag vectors.

    header = struct( 'Fs', samprate, 'nChans', chancount, ...
      'nSamples', sampcount, 'nSamplesPre', 0, 'nTrials', 1, ...
      'label', {channames}, 'chantype', {chantypes}, ...
      'chanunit', {chanunits}, ...
      'channativezero', {channativezero}, ...
      'channativescale', {channativescale}, ...
      'chanflagbits', {chanflagbits} );
  end
end


% Done.

end


%
% This is the end of the file.
