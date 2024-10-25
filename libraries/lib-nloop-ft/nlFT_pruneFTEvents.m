function newlist = nlFT_pruneFTEvents(oldlist)

% function newlist = nlFT_pruneFTEvents(oldlist)
%
% This traverses a list of events stored in Field Trip format, removing
% event records which, for a given "type", have the same "value" as the
% previously-seen event of that "type".
%
% This is intended to be used with event lists generated by the LoopUtil
% library, which store TTL state changes as events with "type" holding the
% channel label.
%
% "oldlist" is the Field Trip event list to process.
%
% "newlist" is the pruned list.


prevstate = struct();

newlist = struct();
newcount = 0;

% FIXME - Iterating this way is slow, but it's easy to debug.
for eidx = 1:length(oldlist)
  thisrec = oldlist(eidx);
  thistype = thisrec.type;

  waschanged = true;
  if isfield(prevstate, thistype)
    if thisrec.value == prevstate.(thistype)
      waschanged = false;
    end
  end

  if waschanged
    prevstate.(thistype) = thisrec.value;
    newcount = newcount + 1;

    if newcount > 1
      newlist(newcount) = thisrec;
    else
      newlist = thisrec;
    end
  end
end


% Done.

end


%
% This is the end of the file.
