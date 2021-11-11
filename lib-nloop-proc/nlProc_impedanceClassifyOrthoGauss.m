function labels = nlProc_impedanceClassifyOrthoGauss( ...
  magdata, phasedata, classdefs, maxdistance, defaultlabel )

% function labels = nlProc_impedanceClassifyOrthoGauss( ...
%   magdata, phasedata, classdefs, maxdistance, defaultlabel )
%
% This tests a series of impedance values, applying cluster labels as
% defined by the supplied class definitions. Samples that can't be clustered
% are given a default cluster label.
%
% This function tests against "orthogauss" models, as defined in
% "ZMODELS.txt".
%
% "magdata" is a set of impedance magnitude values. This is typically
%   the logarithm of the actual magnitude.
% "phasedata" is a set of impedance phase values, in radians.
% "classdefs" is a structure indexed by category label, with each field
%   containing a structure that defines the category's cluter, per
%   "ZMODELS.txt". Only "orthogauss" definitions are processed by this
%   function.
% "maxdistance" is the maximum distance from a cluster center (in standard
%   deviations) that a sample can have while being a member of that cluster.
% "defaultlabel" is a character array to be applied as a category label for
%   data points that do not match any cluster definition.
%
% "labels" is a cell array containing cluster labels for each data point.


% Initialize output.
labels = cell(size(magdata));
labels(:) = { defaultlabel };


% Wrap input phase.
phasedata = mod(phasedata, 2*pi);


% Walk through the categories, applying tests.

bestdistances = zeros(size(magdata));
bestdistances(:) = inf;

classlabels = fieldnames(classdefs);
for cidx = 1:length(classlabels)

  thislabel = classlabels{cidx};

  % Only process classes that are of "orthogauss" type.
  thismodel = classdefs.(thislabel);
  if isfield(thismodel, 'type') && strcmp('orthogauss', thismodel.type)

    % This is an "orthogauss" model. Test against it.

    magmean = thismodel.magmean;
    magdev = thismodel.magdev;
    phasemean = thismodel.phasemean;
    phasedev = thismodel.phasedev;

    distancelist = nlProc_impedanceCalcDistanceToOrthoGauss( ...
      magdata, phasedata, magmean, magdev, phasemean, phasedev );

    % Squash anything out of range.
    catflags = distancelist <= maxdistance;
    distancelist(~catflags) = inf;

    % Update any distances and category labels that match this cluster
    % better than their previous best match.

    catflags = distancelist < bestdistances;
    bestdistances(catflags) = distancelist(catflags);
    labels(catflags) = { thislabel };

  end

end


% Done.

end


%
% This is the end of the file.
