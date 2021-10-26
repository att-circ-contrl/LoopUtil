function newseries = ...
  nlProc_rollAndPadCount( oldseries, rollsamps, padsamps )

% function newseries = ...
%   nlProc_rollAndPadCount( oldseries, rollsamps, padsamps )
%
% This performs DC and ramp removal, applies a Tukey (cosine) roll-off
% window, and pads the endpoints of the supplied signal.
%
% "oldseries" is the series to process.
% "rollsamps" is the length in samples of the starting and ending roll-offs.
% "padsamps" is the number of starting and ending padding samples to add.
%
% "newseries" is the processed signal.


newseries = oldseries;
sampcount = length(oldseries);

newseries = nlUtil_forceRow(newseries);


if (1 == sampcount)
  newseries = 0;
elseif (1 < sampcount)

  % Ramp subtraction.

  xvals = 1:sampcount;
  coeffs = polyfit(xvals, newseries, 1);
  newseries = newseries - nlUtil_forceRow( polyval(coeffs, xvals) );


  % Tukey window roll-off.

  if (0 < rollsamps)
    % 0 is a top-hat window, 1 is a von Hann window.
    rollfrac = 2 * rollsamps / sampcount;
    rollfrac = min(rollfrac, 1);
    rollfrac = max(rollfrac, 0);

    rollseries = tukeywin(sampcount, rollfrac);

    newseries = newseries .* nlUtil_forceRow(rollseries);
  end


  % Padding.

  if (0 < padsamps)
    scratch = [];
    scratch(1:padsamps) = 0;

    scratch((1 + padsamps):(sampcount + padsamps)) = newseries;
    scratch((1 + sampcount + padsamps):(padsamps + sampcount + padsamps)) = 0;

    newseries = nlUtil_forceRow(scratch);
  end

end


% Done.

end


%
% This is the end of the file.
