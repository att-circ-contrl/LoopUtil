function is_ok = nlIO_writeTextFile(fname, textcontent)

% function is_ok = nlIO_writeTextFile(fname, textcontent)
%
% This attempts to write the specified character vector as ASCII text.
% This is a wrapper for "nlIO_writeBinaryData" with type 'char*1'.
%
% "fname" is the name of the file to write to.
% "textcontent" is a character vector containing the text to write.
%
% "is_ok" is true if the operation succeeds and false otherwise.


% I've had to look this up enough times that writing a wrapper is easier.
is_ok = nlIO_writeBinaryFile( fname, textcontent, 'char*1' );


% Done.
end


%
% This is the end of the file.
