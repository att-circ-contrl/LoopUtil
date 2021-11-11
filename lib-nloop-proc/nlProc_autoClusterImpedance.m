function zmodels = ...
  nlProc_autoClusterImpedance( magdata, phasedata, phaseunits )

% function zmodels = ...
%   nlProc_autoClusterImpedance( magdata, phasedata, phaseunits )
%
% This attempts to build sensible cluster definitions covering the specified
% impedance magnitude and phase data. Cluster models are described in
% "ZMODELS.txt".
%
% NOTE - Magnitude input is in ohms and phase input may be radians or degrees,
% but model parameters use log10(ohms) and radians exclusively.
%
% "magdata" is a set of impedance magnitude values, in ohms.
% "phasedata" is a corresponding set of impedance phase values.
% "phaseunits" is 'degrees' or 'radians'.
%
% "zmodels" is a structure containing zero or more models of the data, indexed
%   by model type (typically 'box' and 'orthogauss').
%
% A 'box' model is a structure indexed by category label with the following
% fields:
%   "type" is 'box'.
%   "magrange" [min max] is the range of accepted log10(magnitude) values.
%   "phaserange" [min max] is the range of accepted phases in radians.
% A category label is applied to a sample if that sample's magnitude and
% phase are within the specified ranges.
%
% An 'orthogauss' model is a structure indexed by category label with the
% following fields:
%   "type" is 'orthogauss'.
%   "magmean" is the mean of log10(magnitude) for this category.
%   "magdev" is the standard deviation of log10(magnitude) for this category.
%   "phasemean" is the mean direction of phase for this category in radians.
%   "phasedev" is the standard deviation of (phase - mean) for this category.
% The category label of a sample is the category whose probability density
% function is highest for that sample.


% Initialize to an empty model list.
zmodels = struct();


% Convert to log10 ohms and to radians.
% We need to be in radians to compute mean direction.
% Phase gets wrapped later for binning.

magdata = log10(magdata);

isdegrees = strcmp('degrees', phaseunits);
if isdegrees
  phasedata = phasedata * pi / 180;
end

% Wrap phase to 0..2pi, so that we can bin more easily.
phasedata = mod(phasedata, 2*pi);


% FIXME - We are cheating our pants off, using a priori knowledge of what
% impedance data usually looks like.

% Valid impedances are generally in the -120 degree to 0 degree range,
% and have blobs that span around 30 degrees in phase and half a decade in
% magnitude. They may be slightly tilted but are usually close to being
% axis-aligned.

% "Bad" impedances, as well as true short-circuits to ground, usually have
% widely-scattered phase.
% I've seen clusters with tightly-grouped phase far from the expected range,
% so make sure to tolerate that.

% Human-readable units: Ohms and degrees.

typshort = 1e3;  % Ohms
typopen = 1e7;   % Ohms
typphasewidth = 30;  % Degrees
typmagwidth = 2;  % Factor of

% Phase range to accept for "normal" clusters. Make this generous.
validphases = [ -150 30 ];  % Degrees


% Convert to log(10) ohms and to radians.

typshort = log10(typshort);
typopen = log10(typopen);
typphasewidth = typphasewidth * pi / 180;
typmagwidth = log10(typmagwidth);
validphases = validphases * pi / 180;


% The Right Way to do clustering is to run expectation maximization and get a
% multivariate Gaussian mixture model.

% What we're doing instead is something like a greedy Hough transform:
% Using each data point as "evidence" for a cluster center, picking the
% prospective center with the most evidence, fitting the cluster, subtracting
% anything that's cleanly in that cluster, and repeating on the residue.


% FIXME - We're finding prospective cluster centers using the "box" model
% and refining by fitting the "orthogauss" model. We then work back from the
% "orthogauss" fit to get a "box" model to report.

% Clustering and binning parameters.

wantexplainedfrac = 0.95;
wantminclustsize = 4;

% Number of bins needed to span "typical" widths.
% Values of 3..5 work well.
binfactor = 3;

% FIXME - Magic numbers of refining cluster fit estimates.
clustercutoffsigma = 3.0;
clusterrefinesteps = 3;

% This is a second cutoff used for getting "box" model boundaries.
% This is generally closer than "clustercutoffsigma".
% NOTE - 3 sigma is a bit generous, but anything smaller has outliers right
% next to clusters.
clusterboxcutoff = 3.0;

% This is a constraint on cluster deviation, as deviation can otherwise grow
% without bound during refinement. It's a multiple of "typical" size.
clustermaxmag = 0.7;
clustermaxphase = 0.7;


% Values derived from clustering/binning parameters.

wantminleft = round( length(magdata) * (1 - wantexplainedfrac) );

phasebinsize = typphasewidth / binfactor;
magbinsize = typmagwidth / binfactor;

phasebincount = ceil(2 * pi / phasebinsize);
phasebinsize = 2 * pi / phasebincount;

magstart = typshort;
magend = typopen;
magbincount = ceil( (magend - magstart) / magbinsize );
magbinsize = (magend - magstart) / magbincount;

% Add extra bins at the end for "short" and "open" cases.
magstart = magstart - magbinsize;
magend = magend + magbinsize;
magbincount = magbincount + 2;



% Iterate until we've either explained everything we wanted to or until
% we can't make a decent-sized cluster.

residuemag = magdata;
residuephase = phasedata;
clusterdata = [];

done = false;
if length(residuemag) < wantminleft
  done = true;
end

while ~done

  % Bin the data.

  bincounts = zeros(magbincount, phasebincount);

  % We can actually calculate bin indices in parallel.

  % Already log10.
  magidx = 1 + floor( (residuemag - magstart) / magbinsize );
  magidx = max(1, min(magidx, magbincount));
  % Already 0..2pi.
  phaseidx = 1 + floor(residuephase / phasebinsize);
  phaseidx = max(1, min(phaseidx, phasebincount));

  % Bin sequentially.
  for didx = 1:length(residuemag)
    thismidx = magidx(didx);
    thispidx = phaseidx(didx);
    bincounts(thismidx,thispidx) = bincounts(thismidx,thispidx) + 1;
  end


  % Find the bin with the largest number of samples.

  % The first call to max() collapses rows, giving per-column maxima.
  % Find the column that contains the maximum value.
  colmaxes = max(bincounts);
  maxcolidx = find(colmaxes == max(colmaxes));
  % Handle the case where multiple columns contain the maximum.
  maxcolidx = min(maxcolidx);

  % Extract this column and find the row index.
  thiscolumn = bincounts(:,maxcolidx);
  maxrowidx = find(thiscolumn == max(thiscolumn));
  maxrowidx = min(maxrowidx);


  % Get our first guess at the cluster's membership.

  % NOTE - We can't just select this bin alone. We need everything within
  % a suitable range of it.
  % "Suitable range" is within "typical" width of the center, or "binfactor"
  % bins of the central bin.

  % Magnitude is row, phase is column.

  magidxflags = magidx - maxrowidx;
  magidxflags = ( abs(magidxflags) <= binfactor );

  phaseidxflags = phaseidx - maxcolidx;
  phaseidxflags = ( abs(phaseidxflags) <= binfactor );

  memberflags = magidxflags & phaseidxflags;

  membermags = residuemag(memberflags);
  memberphases = residuephase(memberflags);


  % Iteratively refine our estimate of the cluster's membership.
  % Do this by fitting putative members, then selecting everything that's
  % within range as the new membership estimate.

  for cidx = 1:clusterrefinesteps
    % Get an OrthoGauss fit to this member list.
    [ magmean, magdev, phasemean, phasedev ] = ...
      nlProc_impedanceFitOrthoGauss(membermags, memberphases);

    % FIXME - Handle fit creep by clamping deviations.
    magdev = min(magdev, clustermaxmag * typmagwidth);
    phasedev = min(phasedev, clustermaxphase * typphasewidth);

    % Get a better estimate of cluster membership.

    memberflags = nlProc_impedanceCalcDistanceToOrthoGauss( ...
      residuemag, residuephase, magmean, magdev, phasemean, phasedev );
    memberflags = (memberflags < clustercutoffsigma);

    membermags = residuemag(memberflags);
    memberphases = residuephase(memberflags);
  end

  % Get the final canonical OrthoGauss fit.
  [ magmean, magdev, phasemean, phasedev ] = ...
    nlProc_impedanceFitOrthoGauss(membermags, memberphases);

  % FIXME - Handle fit creep by clamping deviations.
  magdev = min(magdev, clustermaxmag * typmagwidth);
  phasedev = min(phasedev, clustermaxphase * typphasewidth);


  % Record this entry and check exit conditions.

  if length(membermags) < wantminclustsize
    % We couldn't find a big enough cluster. Terminate.
    done = true;
  else
    % Record this cluster's parameters.
    thiscluster = struct( ...
      'magmean', magmean, 'magdev', magdev, ...
      'phasemean', phasemean, 'phasedev', phasedev );

    clustercount = 1 + length(clusterdata);
    if 1 == clustercount
      clusterdata = thiscluster;
    else
      clusterdata(clustercount) = thiscluster;
    end
  end

  % Remove identified members and terminate if we don't have enough left.
  residuemag = residuemag(~memberflags);
  residuephase = residuephase(~memberflags);
  if length(residuemag) < wantminleft
    done = true;
  end

end



% Build cluster models and labels.

boxmodels = struct();
orthomodels = struct();

shortcount = 0;
opencount = 0;
normalcount = 0;
badcount = 0;

for cidx = 1:length(clusterdata)

  thismodel = clusterdata(cidx);

  % Read orthogauss parameters from the fit.
  magmean = thismodel.magmean;
  magdev = thismodel.magdev;
  phasemean = thismodel.phasemean;
  phasedev = thismodel.phasedev;

  % Estimate box parameters.
  delta = magdev * clusterboxcutoff;
  magrange = [ magmean - delta, magmean + delta ];
  delta = phasedev * clusterboxcutoff;
  phaserange = [ phasemean - delta, phasemean + delta ];

  % Wrap phase to -pi..pi.
  % For phase range, this may mean "max" is less than "min". This is ok.
  phaserange = mod(phaserange + pi, 2*pi) - pi;
  phasemean = mod(phasemean + pi, 2*pi) - pi;


  % Guess at the category label.

  % Accept any phase for shorted and floating clusters.
  thislabel = 'bogus';
  if magmean <= typshort
    shortcount = shortcount + 1;
    thislabel = sprintf('ground%d', shortcount);
  elseif magmean >= typopen
    opencount = opencount + 1;
    thislabel = sprintf('floating%d', opencount);
  elseif (phasemean >= min(validphases)) && (phasemean <= max(validphases))
    normalcount = normalcount + 1;
    thislabel = sprintf('cluster%d', normalcount);
  else
    badcount = badcount + 1;
    thislabel = sprintf('abnormal%d', badcount);
  end


  % Store this data.

  % Keep units as radians and log10(ohms).

  boxmodels.(thislabel) = ...
    struct('type', 'box', 'magrange', magrange, 'phaserange', phaserange);

  orthomodels.(thislabel) = ...
    struct( 'type', 'orthogauss', 'magmean', magmean, 'magdev', magdev, ...
      'phasemean', phasemean, 'phasedev', phasedev );

end


% Store the cluster models.

if ~isempty(clusterdata)
  zmodels = struct( 'box', boxmodels, 'orthogauss', orthomodels );
end



% Done.

end


%
% This is the end of the file.
