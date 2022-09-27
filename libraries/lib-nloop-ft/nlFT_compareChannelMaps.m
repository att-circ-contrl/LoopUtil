function [ firstok secondok logtext ] = nlFT_compareChannelMaps( ...
  firstsrc, firstdst, secondsrc, seconddst )

% function [ firstok secondok logtext ] = nlFT_compareChannelMaps( ...
%   firstsrc, firstdst, secondsrc, seconddst )
%
% This compares two label-based channel maps and flags discrepancies.
%
% "firstsrc" is a cell array of "before mapping" labels for the first map.
% "firstdst" is a cell array of "after mapping" labels for the first map.
% "secondsrc" is a cell array of "before mapping" labels for the second map.
% "seconddst" is a cell array of "after mapping" labels for the second map.
%
% "firstok" is a vector of the same size as "firstsrc" containing "true" for
%   entries that are consistent between the first and second maps.
% "secondok" is a vector of the same size as "secondsrc" containing "true"
%   for entries that are consistent between the first and second maps.
% "logtext" is a character vector containing a human-readable summary report.


% Initialize.

firstok = false(size(firstsrc));
secondok = false(size(secondsrc));

logtext = '';


% Walk through the maps, flagging corresponding entries.

for fidx = 1:length(firstsrc)
  thisfirstsrc = firstsrc{fidx};
  thisfirstdst = firstdst{fidx};

  secondsrcmatches = strcmp(secondsrc, thisfirstsrc);
  seconddstmatches = strcmp(seconddst, thisfirstdst);
  secondmatches = secondsrcmatches & seconddstmatches;

  if 1 == sum(secondmatches)
    % Perfect match.
    sidx = find(secondmatches);
    firstok(fidx) = true;
    secondok(sidx) = true;
  elseif (sum(secondsrcmatches) > 0) || (sum(seconddstmatches) > 0)
    % Multiple matches or half-match.
    logtext = horzcat( logtext, ...
      sprintf(  '.. Mismatch for "%s" -> "%s". Second table has:\n', ...
        thisfirstsrc, thisfirstdst ) );
    secondmatches = secondsrcmatches | seconddstmatches;
    for sidx = find(secondmatches)
      logtext = horzcat( logtext, ...
        sprintf( '  "%s" -> "%s"\n', secondsrc{sidx}, seconddst{sidx} ) );
    end
  else
    % No matches.
    logtext = horzcat( logtext, ...
      sprintf(  '.. No second table entry for "%s" -> "%s".\n', ...
        thisfirstsrc, thisfirstdst ) );
  end
end

logtext = horzcat( logtext, ...
  sprintf( '-- Channel maps have %d good entries (out of %d and %d).\n', ...
    sum(firstok), length(firstok), length(secondok) ) );


% Done.

end


%
% This is the end of the file.
