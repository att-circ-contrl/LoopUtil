function [ changroups rvalues groupdefs ] = ...
  nlProc_findCorrelatedChannels( wavedata, thresh_abs, thresh_rel )

% function [ changroups rvalues groupdefs ] = ...
%   nlProc_findCorrelatedChannels( wavedata, thresh_abs, thresh_rel )
%
% This attempts to find sets of strongly-correlated channels in waveform data.
% These may be floating channels coupling identical noise (for high-frequency
% data) or may be measuring from the same environment (for LFP data).
%
% NOTE - Channel correlation time goes up as the square of the number of
% channels!
%
% Correlation is judged using Pearson's Correlation Coefficient.
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
% "changroups" is a vector indicating which group each channel is a member of,
%   or NaN if a channel is not a member of a group (not strongly correlated).
% "rvalues" is an Nchans*Nchans matrix containing correlation coefficient
%   values for all channel pairs.
% "groupdefs" is a cell array containing vectors representing groups of
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



% Figure out which channels are mutually correlated.

% First pass - make initial groups. This may result in partly-overlapping
% groups (if two channels correlate with a third but not with each other).

groupdefs = {};
groupcount = 0;
scratchlist = true(1,chancount);

for cidx = 1:chancount
  % If we haven't grouped this channel yet, test it.
  if scratchlist(cidx)

    % Figure out which channels this channel is correlated with.

    thischancoeffs = rvalues(:,cidx);
    % Keep self-correlation.

    chanmask = (thischancoeffs > thresh_abs);
    if ~isnan(thresh_rel)
      chanmask = chanmask | (thischancoeffs > thresh_rel);
    end


    % If it's anything other than "just itself", make a new group.

    if sum(chanmask) > 1
      groupcount = groupcount + 1;
      groupdefs{groupcount} = find(chanmask);
      scratchlist(chanmask) = false;
    end

  end
end

% Second pass - merge groups that have channels in common.
% Each channel should belong to at most one group.

oldgroups = groupdefs;
oldgroupcount = groupcount;
groupdefs = {};
groupcount = 0;

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
    for gidx = 1:groupcount
      if ismember(cidx, groupdefs{gidx})
        newgroupid = gidx;
      end
    end

    % Take action depending on whether we found an existing group or not.
    % If this channel was already assigned to a new group, merge with that.
    % Otherwise, save the merged old groups as a new group.

    if newgroupid > 0
      % NOTE - Groups were generated as column vectors.
      groupdefs{newgroupid} = ...
        unique( [ groupdefs{newgroupid} ; allfound ] );
    else
      groupcount = groupcount + 1;
      groupdefs{groupcount} = allfound;
    end

  end

end


% Lastly, walk through the group definitions building the channel group map.

changroups = NaN(1,chancount);

for gidx = 1:length(groupdefs)
  thisgroupdef = groupdefs{gidx};
  changroups(thisgroupdef) = gidx;
end


% Done.

end


%
% This is the end of the file.
