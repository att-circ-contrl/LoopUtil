function logtext = nlFT_evalChannelMapFit( ...
  srclabels, dstlabels, data_before, data_after, rmatrix, pmatrix )

% function logtext = nlFT_evalChannelMapFit( ...
%   srclabels, dstlabels, data_before, data_after, rmatrix, pmatrix )
%
% This evaluates how well a supplied channel mapping matches correlations
% between channels in "before" and "after" datasets.
%
% The datasets must have the same sampling rate, the same number of trials,
% and the same number of samples in corresponding trials.
%
% NOTE - Computing correlation values is slow! Time goes up as the square of
% the number of channels.
%
% "srclabels" is a cell array containing channel labels from "data_before".
% "dstlabels" is a cell array containing corresponding channel labels from
%   "data_after".
% "data_before" is a Field Trip dataset prior to channel mapping.
% "data_after" is a Field Trip dataset after channel mapping.
% "rmatrix" is the matrix of R-values returned by nlFT_getChannelCorrelMatrix.
%   If this argument is omitted, the R-value matrix is recomputed.
% "pmatrix" is the matrix of P-values returned by nlFT_getChannelCorrelMatrix.
%   If this argument is omitted, the P-value matrix is recomputed.
%
% "logtext" is a character vector containing a human-readable summary report.


logtext = '';


if ~( exist('rmatrix', 'var') && exist('pmatrix', 'var') )
  % NOTE - This is slow!
  [ rmatrix pmatrix ] = ...
    nlFT_getChannelCorrelMatrix( data_before, data_after );
end


beforelabels = data_before.label;
afterlabels = data_after.label;

for lidx = 1:length(srclabels)
  thissrc = srclabels{lidx};
  thisdst = dstlabels{lidx};

  srcidx = find(strcmp(beforelabels, thissrc));
  dstidx = find(strcmp(afterlabels, thisdst));

  if (1 ~= length(srcidx)) || (1 ~= length(dstidx))
    logtext = horzcat( logtext, ...
      sprintf( '## Pair "%s" -> "%s" isn''t in data!\n', thissrc, thisdst ) );
  else
    logtext = horzcat( logtext, ...
      sprintf( '.. Pair "%s" -> "%s":\n', thissrc, thisdst ) );

    thiseval = helper_evalPair( thissrc, thisdst, afterlabels, ...
      rmatrix(srcidx,:), pmatrix(srcidx,:) );
    logtext = horzcat( logtext, thiseval );
  end
end


% Done.

end


%
% Helper Functions


function evaltext = helper_evalPair( srclabel, dstlabel, alldstlabels, ...
  dstrvals, dstpvals )

  % Hardcode the number of ranked entries to return.
  outcount = 3;


  % Strip NaN entries.

  nanmask = isnan(dstrvals) | isnan(dstpvals);

  alldstlabels = alldstlabels(~nanmask);
  dstrvals = dstrvals(~nanmask);
  dstpvals = dstpvals(~nanmask);


  % Get the N best-ranked R- and P-values and their labels.

  [rsorted, rsortidx] = sort(dstrvals, 'descend');
  [psorted, psortidx] = sort(dstpvals, 'ascend');

  outcount = min(outcount, length(alldstlabels));

  rsortidx = rsortidx(1:outcount);
  psortidx = psortidx(1:outcount);

  rsorted = dstrvals(rsortidx);
  rlabels = alldstlabels(rsortidx);

  psorted = dstpvals(psortidx);
  plabels = alldstlabels(psortidx);


  % Generate appropriate text.

  evaltext = '';

  if strcmp(rlabels{1}, dstlabel)
    evaltext = horzcat( evaltext, '  R:  (match)', newline );
  else
    evaltext = horzcat( evaltext, '  R:' );
    found = false;

    for lidx = 1:length(rlabels)
      if strcmp(dstlabel, rlabels{lidx})
        evaltext = horzcat( evaltext, ' **' );
        found = true;
      else
        evaltext = horzcat( evaltext, '   ' );
      end

      evaltext = horzcat( evaltext, sprintf( '"%s" (%.4f)', ...
        rlabels{lidx}, rsorted(lidx) ) );
    end
    evaltext = horzcat( evaltext, newline );

    if ~found
      lidx = find(strcmp( alldstlabels, dstlabel ));
      if length(lidx) > 0
        lidx = lidx(1);
        evaltext = horzcat( evaltext, ...
          sprintf( '  desired:   "%s" (%.4f)\n', ...
            alldstlabels{lidx}, dstrvals(lidx) ) );
      end
    end
  end

% FIXME - Stub out P-value report.
% Almost all P-values are 0 (due to common-mode?), so the sort isn't useful.
if false

  if strcmp(plabels{1}, dstlabel)
    evaltext = horzcat( evaltext, '  P:  (match)', newline );
  else
    evaltext = horzcat( evaltext, '  P:' );
    found = false;

    for lidx = 1:length(plabels)
      if strcmp(dstlabel, plabels{lidx})
        evaltext = horzcat( evaltext, ' **' );
        found = true;
      else
        evaltext = horzcat( evaltext, '   ' );
      end

      evaltext = horzcat( evaltext, sprintf( '"%s" (%.4f)', ...
        plabels{lidx}, psorted(lidx) ) );
    end
    evaltext = horzcat( evaltext, newline );

    if ~found
      lidx = find(strcmp( alldstlabels, dstlabel ));
      if length(lidx) > 0
        lidx = lidx(1);
        evaltext = horzcat( evaltext, ...
          sprintf( '  desired:   "%s" (%.4f)\n', ...
            alldstlabels{lidx}, dstpvals(lidx) ) );
      end
    end
  end

% FIXME - End of stub out P-value report.
end

end


%
% This is the end of the file.
