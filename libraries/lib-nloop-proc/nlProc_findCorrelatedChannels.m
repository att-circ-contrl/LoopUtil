function [ isgood rvalues badgroups ] = nlProc_findCorrelatedChannels( ...
  wavedata, thresh_abs, thresh_rel )

% function [ isgood rvalues badgroups ] = nlProc_findCorrelatedChannels( ...
%   wavedata, thresh_abs, thresh_rel )
%
% This attempts to find sets of strongly-correlated channels in waveform data.
% Sets like that are usually floating channels coupling identical noise.
%
% This is judged using Pearson's Correlation Coefficient.
%
% "wavedata" is an Nchans*Nsamples matrix containing waveform data.
% "thresh_abs" is an absolute threshold. Channel pairs with correlation
%   coefficients above +thresh_abs are assumed to be copies.
%   NOTE - Differential channel pairs with have coefficients below -thresh_abs;
%   this is okay, and gets taken into account for thresh_rel per below.
% "thresh_rel" is a relative threshold. Channel pairs with correlation
%   coefficients above this multiple of a "typical" correlation coefficient
%   value are assumed to be copies. The "typical" value is the median of the
%   absolute value of all correlation coefficients that are below +thresh_abs
%   and above -thresh_abs.
%
% "isgood" is a vector of boolean values indicating whether channels pass both
%   tests (i.e. are not copies of any other channel).
% "rvalues" is an Nchans*Nchans matrix containing correlation coefficient
%   values for all channel pairs.
% "badgroups" is a cell array containing vectors representing groups of
%   mutually correlated channels. Each vector contains channel indices for
%   the members of that group.


% Get the correlation coefficients.
% NOTE - "corcoeff" expects Nsamples*Nchans data.

rvalues = corrcoef(transpose(wavedata));
chancount = max(size(rvalues));


% Figure out what the "typical" coefficient value is and set a relative
% threshold.

% Take one half of the matrix and also ignore the diagonal.
coefflist = [];
for cidx = 2:chancount
  for didx = 1:(cidx-1)
    thiscoeff = rvalues(cidx,didx);
    coefflist = [coefflist thiscoeff];
  end
end

coefflist = abs(coefflist);
coefflist = coefflist(coefflist < thresh_abs);

% This will be NaN if all coefficients failed the absolute test.
thresh_rel = thresh_rel * median(coefflist);


% Figure out which channels are "good".

isgood = logical([]);
for cidx = 1:chancount

  % Get the coefficients for this channel.
  thischancoeffs = rvalues(:,cidx);

  % The channel will always correlate with itself.
  thischancoeffs(cidx) = NaN;
  thischancoeffs = thischancoeffs(~isnan(thischancoeffs));

  % Check for coefficients that are too positive.
  % Negative is okay; that indicates differential channel pairs.
  thisgood = true;
  if any(thischancoeffs > thresh_abs)
    thisgood = false;
  end
  if (~isnan(thresh_rel)) && any(thischancoeffs > thresh_rel)
    thisgood = false;
  end

  isgood(cidx) = thisgood;
end


% Figure out which channels are mutually correlated.

% First pass - make initial groups. This may result in partly-overlapping
% groups (if two channels correlate with a third but not with each other).

badgroups = {};
badgroupcount = 0;
scratchlist = true(size(isgood));

for cidx = 1:chancount
  % If we haven't grouped this channel yet, test it.
  if scratchlist(cidx)

    % Figure out which channels this channel is correlated with.

    thischancoeffs = rvalues(:,cidx);
    % Keep self-correlation, this time.

    chanmask = (thischancoeffs > thresh_abs);
    if ~isnan(thresh_rel)
      chanmask = chanmask | (thischancoeffs > thresh_rel);
    end


    % If it's anything other than "just itself", make a new group.

    if sum(chanmask) > 1
      badgroupcount = badgroupcount + 1;
      badgroups{badgroupcount} = find(chanmask);
      scratchlist(chanmask) = false;
    end

  end
end

% Second pass - merge groups that have channels in common.
% Each channel should belong to at most one group.

oldgroups = badgroups;
oldgroupcount = badgroupcount;
badgroups = {};
badgroupcount = 0;

for cidx = 1:chancount

  % See if this channel is a member of any group.
  % Get the union of the group memberships if so.

  allfound = [];

  for gidx = 1:oldgroupcount
    if ismember(cidx, oldgroups{gidx})
      % NOTE - Groups were generated as column vectors.
      allfound = unique( [ allfound ; oldgroups{gidx} ]);
    end
  end

  % If this channel is a member of any group, figure out what new group it
  % should be in.

  if length(allfound) > 0

    % We're part of a group.
    % See if we're also part of an already-saved group.

    newgroupid = 0;
    for gidx = 1:badgroupcount
      if ismember(cidx, badgroups{gidx})
        newgroupid = gidx;
      end
    end

    % Take action depending on whether we found an existing group or not.
    % If this channel was already assigned to a new group, merge with that.
    % Otherwise, save the merged old groups as a new group.

    if newgroupid > 0
      % NOTE - Groups were generated as column vectors.
      badgroups{newgroupid} = unique( [ badgroups{newgroupid} ; allfound ] );
    else
      badgroupcount = badgroupcount + 1;
      badgroups{badgroupcount} = allfound;
    end

  end

end


% Done.

end


%
% This is the end of the file.
