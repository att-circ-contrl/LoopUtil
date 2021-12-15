function ztable = nlIO_readAndBinImpedance( fnamelist, ...
  chancolumn, magcolumn, phasecolumn, phaseunits, bindefs, testorder )

% function ztable = nlIO_readAndBinImpedance( fnamelist, ...
%   chancolumn, magcolumn, phasecolumn, phaseunits, bindefs, testorder )
%
% This reads one or more CSV files containing channel impedance measurements.
% Impedance measurements are averaged across files, and channels are tagged
% with type labels based on user-specified criteria (typical types are
% high-impedance, low-impedance, grounded, and floating).
%
% For automated clustering, supply an empty cell array for "testorder"
% (the contents of "bindefs" are ignored in this situation).
%
% When multiple measurements for a given channel ID label are present,
% the magnitude is averaged using the geometric mean (to tolerate large
% differences in magnitude) and the phase angle is averaged using
% circular statistics (mean direction).
%
% NOTE - Phase units are not modified, but we need to know what the units
% are in order to compute the mean direction when averaging phase samples.
%
% NOTE - Phase is wrapped to +/- 180 deg (+/- pi radians).
%
% NOTE - This needs Matlab R2019b or later for 'PreserveVariableNames'.
% It'll still work in older versions but will alter column names to be
% Matlab-safe (use matlab.lang.makeValidName() to duplicate this).
%
% "fnamelist" is a cell array containing the names of files to read. These
%   are expected to be CSV files.
% "chancolumn" is the table column to read channel ID labels from.
% "magcolumn" is the table column to read impedance magnitude from.
% "phasecolumn" is the table column to read impedance phase from.
% "phaseunits" is 'degrees' or 'radians'.
% "bindefs" is a category definition structure per "nlProc_binTableDataSimple".
% "testorder" is the order in which to test category definitions. The first
%   label is the default label, and the _last_ label with a successful test
%   is applied. If this is empty, it forces automatic cluster detection.
%
% "ztable" is a table containing the following columns:
%   "label" is a copy of the "chancolumn" input column.
%   "magnitude" is a copy of the "magcolumn" input column.
%   "phase" is a copy of the "phasecolumn" input column.
%   "type" is the category label for each channel.


ztable = table();


% Figure out if we want automated binning.
% NOTE - Force auto-clustering even with non-empty bindefs!
want_auto_cluster = isempty(testorder);


% First pass: Read and aggregate the input file data.

chanmags = {};
chanphases = {};
chanindices = containers.Map('KeyType', 'char', 'ValueType', 'double');
chancount = 0;

for fidx = 1:length(fnamelist)

  thisfile = fnamelist{fidx};

  if ~isfile(thisfile)
    disp(sprintf('### Unable to read from "%s".', thisfile));
  else

    % Read data from this file.

    thislabelcol = {};
    thismagcol = [];
    thisphasecol = [];

    if verLessThan('matlab', '9.7')
      % Before R2019b. Can't preserve variable names.
      thistab = readtable(thisfile);
    else
      % R2019b or later.
      thistab = readtable(thisfile, 'PreserveVariableNames', true);
    end
    colnames = thistab.Properties.VariableNames;

    if ismember(chancolumn, colnames)
      thislabelcol = thistab.(chancolumn);
    else
      disp(sprintf('### No "%s" column in "%s".', chancolumn, thisfile));
    end

    if ismember(magcolumn, colnames)
      thismagcol = thistab.(magcolumn);
    else
      disp(sprintf('### No "%s" column in "%s".', magcolumn, thisfile));
    end

    if ismember(phasecolumn, colnames)
      thisphasecol = thistab.(phasecolumn);
    else
      disp(sprintf('### No "%s" column in "%s".', phasecolumn, thisfile));
    end


    % If we found the columns we needed, add them to the aggregate.

    if (~isempty(thislabelcol)) && (~isempty(thismagcol)) ...
      && (~isempty(thisphasecol))
      for ridx = 1:length(thislabelcol)
        thislabel = thislabelcol{ridx};
        thismag = thismagcol(ridx);
        thisphase = thisphasecol(ridx);

        if ~isKey(chanindices, thislabel)
          chancount = chancount + 1;
          chanindices(thislabel) = chancount;

          chanmags{chancount} = [];
          chanphases{chancount} = [];
        end

        thisindex = chanindices(thislabel);

        chanmags{thisindex} = [ chanmags{thisindex} thismag ];
        chanphases{thisindex} = [ chanphases{thisindex} thisphase ];
      end
    end

  end
end


% Second pass: Average the aggregate data.

newlabelcol = {};
newmagcol = [];
newphasecol = [];

isdegrees = strcmp('degrees', phaseunits);

newlabelcol = keys(chanindices);
% Force lexical order.
newlabelcol = sort(newlabelcol);

% Force this to be a column vector.
if ~iscolumn(newlabelcol)
  newlabelcol = transpose(newlabelcol);
end

for lidx = 1:length(newlabelcol)
  thislabel = newlabelcol{lidx};
  thisindex = chanindices(thislabel);
  thismag = chanmags{thisindex};
  thisphase = chanphases{thisindex};


  % For magnitude, take the geometric mean.
  % This tolerates large variations in magnitude.

  if ~isempty(thismag)
    thismag = exp(mean(log(thismag)));
  end


  % For phase, compute the mean direction.

  if ~isempty(thisphase)
    if isdegrees
      thisphase = thisphase * pi / 180;
    end

    thisphase = angle(mean(exp(i * thisphase)));

    if isdegrees
      thisphase = thisphase * 180 / pi;
    end
  end


  % Add this data to the column vectors.
  % Explicitly force these to be column vectors, not row vectors.
  newmagcol(lidx,1) = thismag;
  newphasecol(lidx,1) = thisphase;
end



%
% Third pass: Apply category labels.

newtypecol = cell(size(newlabelcol));
newtypecol(:) = {'bogus'};

if want_auto_cluster
  % Use "orthogauss" with sensible parameters.

  zmodels = nlProc_autoClusterImpedance( newmagcol, newphasecol, phaseunits );

  % Explicitly test to make sure we got a model.
  % If there were no clusters, the auto-clustering function doesn't produce
  % models.
  orthomodel = struct();
  if isfield(zmodels, 'orthogauss')
    orthomodel = zmodels.('orthogauss');
  end

  % Remember that the model uses log10 magnitude and radian phase.
  maglog = log10(newmagcol);
  phaserad = newphasecol;
  if isdegrees
    phaserad = phaserad * pi / 180;
  end

  newtypecol = nlProc_impedanceClassifyOrthoGauss( ...
    maglog, phaserad, orthomodel, 3.0, 'outlier' );
else
  % User-defined clusters.
  % Wrap the simple binning function.

  scratchtab = table( newmagcol, newphasecol, ...
    'VariableNames', {'magnitude', 'phase'} );
  scratchtab = ...
    nlProc_binTableDataSimple( scratchtab, bindefs, testorder, 'type' );
  newtypecol = scratchtab.('type');
end


%
% Final pass: Assemble the table.

ztable = table( newlabelcol, newmagcol, newphasecol, newtypecol, ...
  'VariableNames', {'label', 'magnitude', 'phase', 'type'} );



% Done.

end


%
% This is the end of the file.
