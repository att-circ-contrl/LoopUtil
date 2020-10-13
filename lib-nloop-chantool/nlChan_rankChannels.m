function [ bestlist typbest typmiddle typworst ] = ...
  nlChan_rankChannels( chanrecs, maxperbank, typfrac, scorefunc )

% function [ bestlist typbest typmiddle typworst ] = ...
%   nlChan_rankChannels( chanrecs, maxperbank, typfrac, scorefunc )
%
% This process a list of channel records returned by nlChan_iterateChannels().
% Channel records receive a score, and the list is sorted by that score.
% Statistics for typical records and aggregate statistics are returned.
% The sorted list is pruned to include at most a certain number of channels
% per bank, and is then returned.
% NOTE - The "typical" records are not necessarily in the pruned result list.
%
% "chanrecs" is the list of channel statistics records to process.
% "maxperbank" is the maximum number of channels per bank in the returned list.
% "typfrac" is the percentile for finding "typical" good and bad records.
%   This is a number between 0 and 50 (typically 5, 10, or 25).
% "scorefunc" is a function handle that is called for each channel. It has
%   the form:
%     scoreval = scorefunc(resultval)
%   The "resultval" argument is the chanrecs(n).result field, per
%   nlChan_iterateChannels().
%   Higher scores are better, for purposes of this function. A score of NaN
%   squashes a result (removing it from the result list).
%
% "bestlist" is a subset of the sorted channel record list containing the
%   highest-scoring entries subject to the constraints described above.
% "typbest" is the channel record for the top Nth percentile channel.
% "typmiddle" is the channel record for the median channel.
% "typworst" is the channel record for the bottom Nth percentile channel.


% Force input sanity.

maxperbank = max(1, maxperbank);

typfrac = min(0.5, typfrac);
typcount = floor(typfrac * length(chanrecs));
typcount = max(1, typcount);



% Proceed if we have a list to process.

if (1 > length(chanrecs))

  % Force output sanity.
  bestlist = chanrecs;

else

  % Sort the full list.

  % Compute scores.
  for cidx = 1:length(chanrecs)
    scorelist(cidx) = scorefunc(chanrecs(cidx).result);
  end

  % Squash NaN entries before sorting.
  keepidx = ~isnan(scorelist);
  scorelist = scorelist(keepidx);
  chanrecs = chanrecs(keepidx);

  % Sort the list.
  [ scorelist sortidx ] = sort(scorelist, 'descend');
  rawsort = chanrecs(sortidx);


  % Get typical results.

  typbest = rawsort(typcount);
  typworst = rawsort(length(rawsort) + 1 - typcount);
  typmiddle = rawsort(floor( 0.5 * (1 + length(rawsort)) ));


  % Build a pruned list of sorted result records.

  banktallies = struct();
  bestlist(1) = rawsort(1);
  banktallies.(rawsort(1).bank) = 1;

  for ridx = 2:length(rawsort)
    thisrec = rawsort(ridx);
    thisbank = thisrec.bank;

    if ~isfield(banktallies, thisbank)
      banktallies.(thisbank) = 0;
    end

    thistally = banktallies.(thisbank);
    if (thistally < maxperbank)
      bestlist(length(bestlist) + 1) = thisrec;
      banktallies.(thisbank) = thistally + 1;
    end
  end

end



%
% Done.

end


%
% This is the end of the file.
