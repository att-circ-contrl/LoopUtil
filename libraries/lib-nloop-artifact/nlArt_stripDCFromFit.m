function newfit = nlArt_stripDCFromFit( oldfit )

% function newfit = nlArt_stripDCFromFit( oldfit )
%
% This squashes the DC component of one or more curve fit descriptors.
%
% This only knows how to modify nlArt_XX curve fits. Curve fit toolbox
% curve fits are returned unchanged.
%
% "oldfit" is a structure with nlArt_XX curve fit parameters per
%   ARTFITPARAMS.txt, or a "cfit" object with curve fit toolbox parameters,
%   or a cell array containing multiple such structures/objects.
%
% "newfit" is a copy of "oldfit" modified to have DC components set to zero.


% Initialize.
newfit = oldfit;


% Figure out what type of descriptor we were passed.

if iscell(newfit)

  % Multiple objects; recurse.
  for fidx = 1:length(newfit)
    newfit{fidx} = nlArt_stripDCFromFit(newfit{fidx});
  end

elseif strcmp('cfit', class(newfit))

  % Curve fit toolbox fit; don't modify it.

elseif ~isstruct(newfit)

  disp('### [nlArt_stripDCFromFit]  bad "oldfit" class.');

elseif ~isfield(newfit, 'fittype')

  disp('### [nlArt_stripDCFromFit]  no "fittype" field in "oldfit".');

else

  % This is one of ours.
  fittype = newfit.fittype;

  % Switch depending on type.
  if strcmp(fittype, 'exp')
    newfit.offset = 0;
  else
    disp([ '### [nlArt_stripDCFromFit]  Unknown curve fit type "' ...
      fittype '".' ]);
  end

end


% Done.
end


%
% This is the end of the file.
