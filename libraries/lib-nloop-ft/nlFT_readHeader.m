function header = nlFT_readHeader(indir)

% function header = nlFT_readHeader(indir)
%
% This probes the specified directory using nlIO_readFolderMetadata(),
% and translates the folder's metadata into a Field Trip header.
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
  foldermeta = foldermeta.folders.('datafolder').banks;


  % Initialize header data.

  samprate = NaN;
  sampcount = NaN;
  chancount = 0;
  channames = {};
  chantypes = {};
  chanunits = {};


  % Iterate through banks.

  banknames = fieldnames(foldermeta);
  for bidx = 1:length(banknames)
    thisbankname = banknames{bidx};
    thisbankmeta = foldermeta.(thisbankname);

    thischanlist = thisbankmeta.channels;
    thisrate = thisbankmeta.samprate;
    thiscount = thisbankmeta.sampcount;
    thistype = thisbankmeta.banktype;
    thisunit = thisbankmeta.fpunits;

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
    elseif length(thischanlist) > 0

      % This bank has the expected rate and lenth. Add it.

      newchanqty = length(thischanlist);

      newchannames = {};
      for cidx = 1:length(thischanlist)
        newchannames{cidx} = ...
          sprintf( '%s_%03d', thisbankname, thischanlist(cidx) );
      end

      channames( (chancount+1):(chancount+newchanqty) ) = newchannames;

      chantypes( (chancount+1):(chancount+newchanqty) ) = { thistype };
      chanunits( (chancount+1):(chancount+newchanqty) ) = { thisunit };

      chancount = chancount + newchanqty;

    end
  end


  % Construct the FT header.

  header = struct();
  if isok
    % Fill in bogus values if we had no channels.
    if isnan(samprate)
      samprate = 0;
    end
    if isnan(sampcount)
      sampcount = 0;
    end

    % Construct the header.
    header = struct( 'Fs', samprate, 'nChans', chancount, ...
      'nSamples', sampcount, 'nSamplesPre', 0, 'nTrials', 1, ...
      'label', {channames}, 'chantype', {chantypes}, ...
      'chanunit', {chanunits} );
  end
end


% Done.

end


%
% This is the end of the file.