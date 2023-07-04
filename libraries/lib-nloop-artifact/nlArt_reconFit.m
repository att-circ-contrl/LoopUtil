function reconwave = nlArt_reconFit( timeseries, fitparams )

% function reconwave = nlArt_reconFit( timeseries, fitparams )
%
% This reconstructs a curve fit over a specified time span.
% This is intended for use with artifact curve-fitting functions.
%
% "timeseries" is a vector with sample timestamps.
% "fitparams" is a structure (with nlArt_XX curve fit parameters) per
%   ARTFITPARAMS.txt or a "cfit" object with curve fit toolbox parameters.
%
% "reconwave" is a vector with reconstructed sample values.


% Initialize output no matter what.
reconwave = zeros(size(timeseries));


% Check to see if this is ours or if it's from the curve fit toolbox.
if strcmp('cfit', class(fitparams))

  % Curve fit toolbox.
  reconwave = feval(fitparams, timeseries);

elseif ~isstruct(fitparams)

  disp('### [nlArt_reconFit]  Bad "fitparams" class.');

elseif ~isfield(fitparams, 'fittype')

  disp('### [nlArt_reconFit]  No "fittype" field in "fitparams".');

else

  % This is one of ours.
  fittype = fitparams.fittype;

  % Check known types.
  if strcmp(fittype, 'exp')

    % f(t) = coeff * exp(t/tau) + offset;
    omega = 1 / fitparams.tau;
    reconwave = fitparams.coeff * exp(timeseries * omega) + fitparams.offset;

  else
    disp([ '### [nlArt_reconFit]  Unknown curve fit type "' fittype '".' ]);
  end

end


% Done.
end


%
% This is the end of the file.
