function foldermeta = nlOpenE_probeFolder( indir )

% function foldermeta = nlOpenE_probeFolder( indir )
%
% This checks for the existence of Open Ephys format data files in the
% specified folder, and constructs a folder metadata structure if data is
% found.
%
% If no data is found, an empty structure is returned.
%
% "indir" is the directory to search.
%
% "foldermeta" is a folder metadata structure, per FOLDERMETA.txt.


% Initialize.

foldermeta = struct();


% We're looking for either "structure.oebin" or "settings.xml".

fileperchan = [ indir filesep 'settings.xml' ];
filemonolithic = [ indir filesep 'structure.oebin' ];


% Process what we can find. Give priority to monolithic data.

if isfile(filemonolithic)

  bankscontinuous = list_open_ephys_binary(filemonolithic, 'continuous');
  banksevents = list_open_ephys_binary(filemonolithic, 'events');
  banksspikes = list_open_ephys_binary(filemonolithic, 'spikes');


  allbanks = struct();


  % Process continuous banks.
  % FIXME - Using black magic to separate merged channel types.

  for bidx = 1:length(bankscontinuous)

    % Open the data file without loading it into memory, to get header data.
    % Also check to see if data was actually recorded (nonzero sample count).
    thisdata = ...
      load_open_ephys_binary(filemonolithic, 'continuous', bidx, 'mmap');
    thisdataheader = thisdata.Header;
    thisdatasize = length(thisdata.Timestamps);
    thisdatatimetype = class(thisdata.Timestamps);
    thisdatanativetype = thisdata.Data.Format{1};

    % FIXME - We can't explicitly close the memmapfile object.
    % FIXME - Matlab's documentation says the memmapfile object can be
    % cleared to release it, but this doesn't seem to work in my tests.
    % FIXME - Count on it vanishing when "thisdata" is reassigned and when
    % exiting function scope. This is an ugly kludge!


    % If we have data, split the real bank into multiple virtual banks.
    if thisdatasize > 0
      % Store common template information.
      thisbankcommon = struct( 'samprate', thisdataheader.sample_rate, ...
        'sampcount', thisdatasize, 'nativetimetype', thisdatatimetype, ...
        'nativedatatype', thisdatanativetype, 'nativemeta', thisdataheader );

      % Split this bank into sub-banks by black magic.
      thisbankmetaset = helper_splitContinuousBank( ...
        thisbankcommon, 'monolithic', filemonolithic, bidx, thisdataheader );

      thisbanknamelist = fieldnames(thisbankmetaset);
      for nidx = 1:length(thisbanknamelist)
        thisname = thisbanknamelist{nidx};
        thisbankmeta = thisbankmetaset.(thisname);

        % Rename duplicates. This will look ugly but should rarely happen.
        if isfield(allbanks, thisname)
          thisname = sprintf('b%d%s', bidx, thisname);
        end

        allbanks.(thisname) = thisbankmeta;
      end
    end
  end


  % FIXME - Events NYI. This is where our digital data ends up!


  % FIXME - Spikes NYI.


  % Assemble the folder metadata structure.
  % FIXME - No native metadata to store, since we can't read settings.xml.

  foldermeta = struct( 'path', indir, 'devicetype', 'openephys', ...
    'banks', allbanks );

elseif isfile(fileperchan)

  % FIXME - Per-channel Open Ephys format NYI!

end


% Done.

end



%
% Helper functions.


% This examines channel metadata within Open Ephys continuous data and
% splits it into banks based on content.
% We need to add "channels", "banktype", "nativezerolevel", "nativescale",
% "fpunits", and "handle".

function bankmetaset = helper_splitContinuousBank( ...
  metacommon, oeformat, oefile, oebankindex, dataheader )

  % Initialize output.
  bankmetaset = struct();

  % Get metadata.
  channelmeta = dataheader.channels;
  channelnames = { channelmeta.channel_name };


  % Extract metadata that we expect to be consistent within banks.

  channeldescs = { channelmeta.description };
  channelscales = [ channelmeta.bit_volts ];
  channelunits = { channelmeta.units };

  % Get prefixes from names. These should also be consistent within banks.
  % We'll get Open Ephys's annotated channel numbers too.

  % Tolerate the "name does not end in a number" case.
  alltokens = regexp( channelnames, '^(.*?)(\d*)$', 'tokens' );

  % There's probably a one-line way to do this, but I'm having trouble
  % finding it.
  % Indexing is alltokens{channelnum}{matchnum}{tokennum}.
  % Since any possible string will match exactly once, "matchnum" is 1.
  channelnamebanks = {};
  channelnamenumbers = [];
  for cidx = 1:length(alltokens)
    channelnamebanks{cidx} = alltokens{cidx}{1}{1};
    thisnum = str2num(alltokens{cidx}{1}{2});
    if isempty(thisnum)
      thisnum = 0;
    end
    channelnamenumbers(cidx) = thisnum;
  end


  % Walk through the unique names in the outer loop, and other parts in the
  % inner loop.

  uniquenames = unique(channelnamebanks);
  uniquedescs = unique(channeldescs);
  uniquescales = unique(channelscales);
  uniqueunits = unique(channelunits);

  for nidx = 1:length(uniquenames)

    % Get this prospective bank name and its selection mask.

    thisname = uniquenames{nidx};
    namemask = strcmp(channelnamebanks, thisname);

    % Walk through the other token permutations and build their masks as well.

    casecount = 0;
    casedescs = {};
    casescales = [];
    caseunits = {};
    casemasks = {};

    for didx = 1:length(uniquedescs)
      thisdesc = uniquedescs{didx};
      descmask = strcmp(channeldescs, thisdesc);
      for sidx = 1:length(uniquescales)
        thisscale = uniquescales(sidx);
        scalemask = (channelscales == thisscale);
        for uidx = 1:length(uniqueunits)
          thisunit = uniqueunits{uidx};
          unitmask = strcmp(channelunits, thisunit);

          selectmask = namemask & descmask & scalemask & unitmask;
          if sum(selectmask) > 0
            casecount = casecount + 1;
            casedescs{casecount} = thisdesc;
            casescales(casecount) = thisscale;
            caseunits{casecount} = thisunit;
            casemasks{casecount} = selectmask;
          end

        end
      end
    end

    % Handle zero, one, or many cases. There really shouldn't be zero.

    if casecount > 1
      % Multiple cases for this channel prefix.
      % Use "PrefixN" rather than "Prefix" as the bank name.

      for cidx = 1:casecount
        thisbank = sprintf('%s%d', thisname, cidx);
        thismeta = metacommon;

        thismask = casemasks{cidx};
        thismeta.channels = channelnamenumbers(thismask);

        % FIXME - Force "analog", "zero is zero".
        thismeta.banktype = 'analog';
        thismeta.nativezerolevel = 0;

        thismeta.nativescale = casescales(cidx);
        thismeta.fpunits = caseunits{cidx};

        % Nonstandard metadata that we still want.
        thismeta.nativedesc = casedescs{cidx};

        thismeta.handle = struct( ...
          'format', 'monolithic', 'type', 'continuous', 'oefile', oefile, ...
          'oebank', oebankindex, 'selectmask', thismask );

        bankmetaset.(thisbank) = thismeta;
      end
    elseif casecount > 0
      % One case for this channel prefix.

      thisbank = thisname;
      thismeta = metacommon;

      thismask = casemasks{1};
      thismeta.channels = channelnamenumbers(thismask);

      % FIXME - Force "analog", "zero is zero".
      thismeta.banktype = 'analog';
      thismeta.nativezerolevel = 0;

      thismeta.nativescale = casescales(1);
      thismeta.fpunits = caseunits{1};

      % Nonstandard metadata that we still want.
      thismeta.nativedesc = casedescs{1};

      thismeta.handle = struct( ...
        'format', 'monolithic', 'type', 'continuous', 'oefile', oefile, ...
        'oebank', oebankindex, 'selectmask', thismask );

      bankmetaset.(thisbank) = thismeta;
    end

  end

end


%
% This is the end of the file.
