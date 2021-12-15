function labels = nlProc_impedanceClassifyBox( ...
  magdata, phasedata, classdefs, testorder, defaultlabel )

% function labels = nlProc_impedanceClassifyBox( ...
%   magdata, phasedata, classdefs, testorder, defaultlabel )
%
% This tests a series of impedance values, applying cluster labels as
% defined by the supplied class definitions. Samples that can't be clustered
% are given a default cluster label.
%
% This function tests against "box" models, as defined in "ZMODELS.txt".
%
% "magdata" is a set of impedance magnitude values. This is typically
%   the logarithm of the actual magnitude.
% "phasedata" is a set of impedance phase values, in radians.
% "classdefs" is a structure indexed by category label, with each field
%   containing a structure that defines the category's cluter, per
%   "ZMODELS.txt". Only "box" definitions are processed by this function.
% "testorder" is a cell array containing category labels, defining the order
%   in which to test for category membership (to disambiguate overlapping
%   categories). The _last_ matching test determines the category label. If
%   this is an empty cell array, an arbitrary order is chosen.
% "defaultlabel" is a character array to be applied as a category label for
%   data points that do not match any cluster definition.
%
% "labels" is a cell array containing cluster labels for each data point.


% Get a test order if one wasn't supplied.

if isempty(testorder)
  % Test fields in lexical order, for consistency between runs.
  testorder = sort(fieldnames(classdefs));
end


% Initialize output.
labels = cell(size(magdata));
labels(:) = { defaultlabel };


% Wrap input phase.
phasedata = mod(phasedata, 2*pi);


% Walk through the categories, applying tests.
% This lets us test the sample array in parallel.

for cidx = 1:length(testorder)

  thislabel = testorder{cidx};

  % Only process classes that exist and are of "box" type.
  if isfield(classdefs, thislabel)
    thismodel = classdefs.(thislabel);
    if isfield(thismodel, 'type') && strcmp('box', thismodel.type)

      % This is a "box" model. Test against it.

      magmin = min(thismodel.magrange);
      magmax = max(thismodel.magrange);

      magflags = (magdata >= magmin) & (magdata <= magmax);

      phaserange = mod(thismodel.phaserange, 2*pi);
      phasemin = min(phaserange);
      phasemax = max(phaserange);

      phaseflags = (phasedata >= phasemin) & (phasedata <= phasemax);
      % Accept whichever range is smaller than pi radians.
      if (phasemax - phasemin) > pi
        phaseflags = ~phaseflags;
      end

      catflags = magflags & phaseflags;

      % Store this label for all matching data points.
      labels(catflags) = { thislabel };

    end
  end

end


% Done.

end


%
% This is the end of the file.
