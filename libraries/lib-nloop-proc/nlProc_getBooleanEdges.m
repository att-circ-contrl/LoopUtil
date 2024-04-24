function [ risesamps fallsamps bothsamps highmidsamps lowmidsamps ] = ...
  nlProc_getBooleanEdges( boolwave )

% function [ risesamps fallsamps bothsamps highmidsamps lowmidsamps ] = ...
%   nlProc_getBooleanEdges( boolwave )
%
% This processes a vector of boolean values, and identifies samples that
% are rising edges (first high after a low), falling edges (first low
% after a high), midpoints of high regions, and midpoints of low regions.
%
% The endpoints of the waveform are not considered edges, and the areas
% adjacent to them are not considered to be well-defined high or low regions.
%
% "boolwave" is a logical vector containing the boolean waveform.
%
% "risesamps" is a vector containing sample indices of rising samples.
% "fallsamps" is a vector containing sample indicies of falling samples.
% "bothsamps" is a vector containing sample indices of both rising and
%   falling samples.
% "highmidsamps" is a vector containing sample indices of the midpoints of
%   regions with high sample values, rounded down.
% "lowmidsamps" is a vector containing sample indices of the midpoints of
%   regions with low sample values, rounded down.


risesamps = [];
fallsamps = [];
bothsamps = [];
highmidsamps = [];
lowmidsamps = [];


sampcount = length(boolwave);
if sampcount >= 2

  % Get the edge locations.

  firstseg = boolwave(1:(sampcount-1));
  secondseg = boolwave(2:sampcount);

  testrise = (~firstseg) & secondseg;
  risesamps = find(testrise) + 1;

  testfall = firstseg & (~secondseg);
  fallsamps = find(testfall) + 1;

  bothsamps = find( testrise | testfall ) + 1;


  % Get high and low regions that have well-defined edges on each side.

  risecount = length(risesamps);
  fallcount = length(fallsamps);

  if (risecount > 0) && (fallcount > 0)
    if risesamps(1) < fallsamps(1)

       % First edge is a rising edge.

       endcount = min(risecount,fallcount);
       highmidsamps = risesamps(1:endcount) + (fallsamps(1:endcount) - 1);
       highmidsamps = floor(0.5 * highmidsamps);

       endcount = min((risecount-1), fallcount);
       if endcount > 0
         lowmidsamps = ...
           (risesamps(2:(endcount+1)) - 1) + fallsamps(1:endcount);
         lowmidsamps = floor(0.5 * lowmidsamps);
       end

    else

       % First edge is a falling edge.

       endcount = min(risecount, (fallcount-1));
       if endcount > 0
         highmidsamps = ...
           risesamps(1:endcount) + (fallsamps(2:(endcount+1)) - 1);
         highmidsamps = floor(0.5 * highmidsamps);
       end

       endcount = min(risecount,fallcount);
       lowmidsamps = (risesamps(1:endcount) - 1) + fallsamps(1:endcount);
       lowmidsamps = floor(0.5 * lowmidsamps);

    end
  end

end



% Done.
end


%
% This is the end of the file.
