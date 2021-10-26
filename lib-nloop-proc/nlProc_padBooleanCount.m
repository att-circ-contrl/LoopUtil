function newflags = nlProc_padBooleanCount( oldflags, padbefore, padafter )

% function newflags = nlProc_padBooleanCount( oldflags, padbefore, padafter )
%
% This processes a vector of boolean values, extending "true" flags
% forwards and backwards in time by the specified number of samples. Samples
% up to "padbefore" ahead of and "padafter" following true samples in the
% original signal are true in the returned signal.
%
% This is a dilation operation. To perform erosion, perform dilation on the
% complement of a vector (i.e.  newflags = ~ padBooleanCount( ~ oldflags )).
% Remember to swap "before" and "after" for the complement vector.
%
% "oldflags" is the boolean vector to process.
% "padbefore" is the number of samples backwards in time to pad.
% "padafter" is the number of samples forwards in time to pad.
%
% "newflags" is the boolean vector with padding performed.


% Force sanity.

oldflags = (oldflags > 0.5);
padbefore = max(padbefore, 0);
padafter = max(padafter, 0);


% Walk through the array forwards and backwards in time, with hysteresis.


newflags = [];
timeout = 0;

for fidx = 1:length(oldflags)
  if oldflags(fidx)
    timeout = padafter + 1;
  end

  if timeout > 0
    newflags(fidx) = true;
    timeout = timeout - 1;
  else
    newflags(fidx) = false;
  end
end


timeout = 0;

for fidx = length(oldflags):-1:1
  if oldflags(fidx)
    timeout = padbefore + 1;
  end

  if timeout > 0
    newflags(fidx) = true;
    timeout = timeout - 1;
  end
end


% Done.

end


%
% This is the end of the file.
