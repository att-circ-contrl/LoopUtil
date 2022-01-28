function nlFT_selectOneFTChannel( chanlabel )

% function nlFT_selectOneFTChannel( chanlabel )
%
% This sets up LoopUtil's channel filtering to pass one specific channel
% using Field Trip's channel label.
%
% This is a wrapper for nlFT_selectChannels().
%
% "chanlabel" is the Field Trip channel label for the desired channel.


nlFT_selectChannels( {}, { chanlabel }, {} );


% Done.

end


%
% This is the end of the file.
