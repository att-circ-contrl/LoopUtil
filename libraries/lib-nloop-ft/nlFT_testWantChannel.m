function iswanted = nlFT_testWantChannel(channelname)

% function iswanted = nlFT_testWantChannel(channelname)
%
% This tests to see if a given channel name is in the list of desired channel
% names, per nlFT_selectChannels().
%
% "channelname" is the channel name to test.
%
% FIXME - This stores state as global variables. This was the least-ugly way
% of implementing channel and bank filtering without modifying Field Trip.


% Import global variables.

global nlFT_selectChannels_nameswanted;

% If this hasn't been initialized, it has a value of "[]". Fix that.
if isempty(nlFT_selectChannels_nameswanted)
  nlFT_selectChannels_nameswanted = {};
end


% Test membership.

iswanted = true;
if ~isempty(nlFT_selectChannels_nameswanted)
  iswanted = false;
  for pidx = 1:length(nlFT_selectChannels_nameswanted)
    thispattern = nlFT_selectChannels_nameswanted{pidx};
    matchlist = regexp(channelname, thispattern);
    if ~isempty(matchlist)
      iswanted = true;
    end
  end
end


% Done.

end


%
% This is the end of the file.
