function evlist = nlFT_makeEmptyEventList()

% function evlist = nlFT_makeEmptyEventList()
%
% This function makes a struct array of length zero with the fields that
% may be returned by ft_read_event().
%
% The idea is to provide a structure that works with both "isempty(evlist)"
% and "foo = [ evlist(:).bar ]".
%
% No arguments.
%
% "evlist" is a struct array of length zero with the required and optional
%   fields.


evlist = struct( 'type', {}, 'sample', {}, 'value', {}, ...
  'offset', {}, 'duration', {}, 'timestamp', {} );


% Done.
end


%
% This is the end of the file.
