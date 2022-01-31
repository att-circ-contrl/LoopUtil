function wordvals = nlOpenE_assembleWords(bytevals, wordtype)

% function wordvals = nlOpenE_assembleWords(bytevals, wordtype)
%
% This function assembles the bytes stored in an event list's "FullWords"
% array into word values. This tolerates a list with zero events.
%
% "bytevals" is a copy of the FullWords array (Nevents x Nbytes uint8 LE).
% "wordtype" is a character array containing the name of the type to promote
%   to (typically 'uint16', 'uint32', or 'uint64').
%
% "wordvals" is a vector containing assembled word values.


% Promote input.
wordtypefunc = str2func(wordtype);
bytevals = wordtypefunc(bytevals);

% Get dimensions.
bytecount = size(bytevals);
evcount = bytecount(1);
bytecount = bytecount(2);

% Process the byte array.
% This tolerates evcount equal to 0.

wordvals = zeros(evcount, 1, wordtype);

for bidx = 1:bytecount
  % Read in big-endian order for ease of assembly.
  thisbyte = bytevals(:,(1 + bytecount - bidx));
  wordvals = wordvals * 256 + thisbyte;
end


% Done.

end


%
% This is the end of the file.
