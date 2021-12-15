function newseries = nlProc_fillNaN( oldseries )

% function newseries = nlProc_fillNaN( oldseries )
%
% This interpolates NaN segments within the series using linear interpolation,
% and then fills in NaNs at the end of the series by replicating samples.
% This makes the derivative discontinuous when filling endpoints but prevents
% large excursions from curve fit extrapolation.
%
% "oldseries" is the series containing NaN segments.
%
% "newseries" is the interpolated series without NaN segments.


timeidx = 1:length(oldseries);
timesparse = timeidx(~isnan(oldseries));
oldsparse = oldseries(~isnan(oldseries));

% FIXME - Used spline interpolation originally, but that has large overshoot.
newseries = interp1(timesparse, oldsparse, timeidx, 'linear', NaN);

timesparse = timeidx(~isnan(newseries));
newsparse = newseries(~isnan(newseries));

newseries = interp1(timesparse, newsparse, timeidx, 'nearest', 'extrap');


%
% Done.

end


%
% This is the end of the file.
