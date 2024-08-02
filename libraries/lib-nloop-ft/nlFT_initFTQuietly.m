function nlFT_initFTQuietly

% function nlFT_initFTQuietly
%
% This initializes field Trip, wrapping the normal console spam, and disables
% most Field Trip messages.
%
% No arguments or return value.


evalc('ft_defaults');

ft_notice('off');
ft_info('off');
ft_warning('off');


% Done.
end


%
% This is the end of the file.
