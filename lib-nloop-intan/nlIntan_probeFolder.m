function foldermeta = nlIntan_probeFolder( indir )

% function foldermeta = nlIntan_probeFolder( indir )
%
% This checks for the existence of Intan-format data files in the specified
% folder, and constructs a folder metadata structure if data is found.
%
% If no data is found, an empty structure is returned.
%
% "indir" is the directory to search.
%
% "foldermeta" is a folder metadata structure, per FOLDERMETA.txt.


% Initialize.

foldermeta = struct();


% Get a file list.

dirfiles = {};
if isdir(indir)
  dirfiles = dir(indir);
  dirfiles = { dirfiles.name };
end


% See if we have a metadata file in the file list.

metafile = '';
devtype = 'none';
if ismember('info.rhd', dirfiles)
  metafile = [ indir, '/info.rhd' ];
  devtype = 'intanrec';
elseif ismember('info.rhs', dirfiles)
  metafile = [ indir, '/info.rhs' ];
  devtype = 'intanstim';
end


% Proceed if so.

if ~isempty(metafile)

  % FIXME - Kludge! We should read the actual native metadata!
  % Right now this manually reads only device type and sampling rate.
  [ isok nativemeta ] = nlIntan_readMetadata(metafile);

  if isok

    % Copy selected metadata elements.
    samprate = nativemeta.samprate;

    % Initialize output.
    foldermeta = struct( 'path', indir, 'devicetype', devtype, ...
      'banks', struct(), 'nativemeta', nativemeta );

    % FIXME - Blithely assume timestamps exist.
    timefile = [ indir, 'time.dat' ];


    %
    % Banks stored in NeuroScope format.

    if ismember('amplifier.dat', dirfiles)
      % FIXME - NYI.
    end

    if ismember('auxiliary.dat', dirfiles)
      % FIXME - NYI.
    end

    if ismember('analogin.dat', dirfiles)
      % FIXME - NYI.
    end

    if ismember('digitalin.dat', dirfiles)
      % FIXME - NYI.
    end

    if ismember('digitalout.dat', dirfiles)
      % FIXME - NYI.
    end


    %
    % Banks stored in per-channel format.


    % Amplifier channels are "amp-A-000.dat" .. "amp-H-127.dat".
    [ chanlist chanbanks chanfiles ] = ...
      helper_getChannelFiles(indir, dirfiles, 'amp-(\w+)-(\d+)\.dat');

    if ~isempty(chanlist)
      uniquebanks = unique(chanbanks);
      for bidx = 1:length(uniquebanks)
        thisbank = uniquebanks{bidx};
        banklabel = [ 'amp', thisbank ];

        selectmask = strcmp(chanbanks, thisbank);
        chansubset = chanlist(selectmask);
        filesubset = chanfiles(selectmask);

        thishandle = struct( 'format', 'onefileperchan', ...
          'chanfilechans', chansubset, 'chanfilenames', { filesubset} );
        foldermeta.banks.(banklabel) = struct( ...
          'channels', chansubset, 'samprate', samprate, ...
          'banktype', 'analog', 'handle', thishandle );
      end
    end


    % Headstage auxiliary channels are "amp-A-AUX1.dat" .. "amp-H-AUX6.dat".
    [ chanlist chanbanks chanfiles ] = ...
      helper_getChannelFiles(indir, dirfiles, 'amp-(\w+)-AUX(\d+)\.dat');

    if ~isempty(chanlist)
      uniquebanks = unique(chanbanks);
      for bidx = 1:length(uniquebanks)
        thisbank = uniquebanks{bidx};
        banklabel = [ 'aux', thisbank ];

        selectmask = strcmp(chanbanks, thisbank);
        chansubset = chanlist(selectmask);
        filesubset = chanfiles(selectmask);

        thishandle = struct( 'format', 'onefileperchan', ...
          'chanfilechans', chansubset, 'chanfilenames', { filesubset} );
        foldermeta.banks.(banklabel) = struct( ...
          'channels', chansubset, 'samprate', samprate, ...
          'banktype', 'analog', 'handle', thishandle );
      end
    end


    % Controller analog inputs are "board-ADC-00.dat" .. "board-ADC-15.dat".
    [ chanlist chanbanks chanfiles ] = ...
      helper_getChannelFiles(indir, dirfiles, 'board-(ADC)-(\d+)\.dat');

    if ~isempty(chanlist)
      % There should be only one bank ("ADC").
      uniquebanks = unique(chanbanks);
      for bidx = 1:length(uniquebanks)
        thisbank = uniquebanks{bidx};
        % FIXME - This will alias if we have more than one bank!
        banklabel = 'Ain';

        selectmask = strcmp(chanbanks, thisbank);
        chansubset = chanlist(selectmask);
        filesubset = chanfiles(selectmask);

        thishandle = struct( 'format', 'onefileperchan', ...
          'chanfilechans', chansubset, 'chanfilenames', { filesubset} );
        foldermeta.banks.(banklabel) = struct( ...
          'channels', chansubset, 'samprate', samprate, ...
          'banktype', 'analog', 'handle', thishandle );
      end
    end


    % Controller digital inputs are "board-DIN-00.dat" .. "board-DIN-15.dat".
    [ chanlist chanbanks chanfiles ] = ...
      helper_getChannelFiles(indir, dirfiles, 'board-(DIN)-(\d+)\.dat');

    if ~isempty(chanlist)
      % There should be only one bank ("DIN").
      uniquebanks = unique(chanbanks);
      for bidx = 1:length(uniquebanks)
        thisbank = uniquebanks{bidx};
        % FIXME - This will alias if we have more than one bank!
        banklabel = 'Din';

        selectmask = strcmp(chanbanks, thisbank);
        chansubset = chanlist(selectmask);
        filesubset = chanfiles(selectmask);

        thishandle = struct( 'format', 'onefileperchan', ...
          'chanfilechans', chansubset, 'chanfilenames', { filesubset} );
        foldermeta.banks.(banklabel) = struct( ...
          'channels', chansubset, 'samprate', samprate, ...
          'banktype', 'ttl', 'handle', thishandle );
      end
    end


    % Digital outputs are "board-DOUT-00.dat" .. "board-DOUT-15.dat".
    [ chanlist chanbanks chanfiles ] = ...
      helper_getChannelFiles(indir, dirfiles, 'board-(DOUT)-(\d+)\.dat');

    if ~isempty(chanlist)
      % There should be only one bank ("DOUT").
      uniquebanks = unique(chanbanks);
      for bidx = 1:length(uniquebanks)
        thisbank = uniquebanks{bidx};
        % FIXME - This will alias if we have more than one bank!
        banklabel = 'Dout';

        selectmask = strcmp(chanbanks, thisbank);
        chansubset = chanlist(selectmask);
        filesubset = chanfiles(selectmask);

        thishandle = struct( 'format', 'onefileperchan', ...
          'chanfilechans', chansubset, 'chanfilenames', { filesubset} );
        foldermeta.banks.(banklabel) = struct( ...
          'channels', chansubset, 'samprate', samprate, ...
          'banktype', 'ttl', 'handle', thishandle );
      end
    end

  end

end


% Done.

end



%
% Helper functions.

% Channel filenames have the form "(prefix)-(bank)-(number).dat".
% We're assuming we're passed a pattern with two tokens, the first of which
% returns character array data and the second of which returns numeric data.

function [ chanlist chanbanks chanfiles ] = ...
  helper_getChannelFiles(indir, dirfiles, pattern)

  chanlist = [];
  chanbanks = {};
  chanfiles = {};

  outcount = 0;

  for fidx = 1:length(dirfiles)

    thisfile = dirfiles{fidx};
    tokenlist = regexp( thisfile, pattern, 'tokens' );

    if ~isempty(tokenlist)
      thisbank = tokenlist{1}{1};
      thischan = str2double(tokenlist{1}{2});

      outcount = outcount + 1;
      chanlist(outcount) = thischan;
      chanbanks{outcount} = thisbank;
      chanfiles{outcount} = [ indir, '/', thisfile ];
    end

  end
end


%
% This is the end of the file.
