function iswanted = nlFT_testWantBank(bankname, banktype)

% function iswanted = nlFT_testWantBank(bankname, banktype)
%
% This tests to see if a given bank is desired, per nlFT_selectChannels().
% A bank is desired if its type and bank name are both acceptable.
%
% "bankname" is the bank name to test.
% "banktype" is the bank type label to test.
%
% FIXME - This stores state as global variables. This was the least-ugly way
% of implementing channel and bank filtering without modifying Field Trip.


% Import global variables.

global nlFT_selectChannels_typeswanted;
global nlFT_selectChannels_bankswanted;

% If anything hasn't been initialized, it has a value of "[]". Fix that.
if isempty(nlFT_selectChannels_typeswanted)
  nlFT_selectChannels_typeswanted = {};
end
if isempty(nlFT_selectChannels_bankswanted)
  nlFT_selectChannels_bankswanted = {};
end


% Test membership.

typeiswanted = true;
if ~isempty(nlFT_selectChannels_typeswanted)
 typeiswanted = ismember(banktype, nlFT_selectChannels_typeswanted);
end

nameiswanted = true;
if ~isempty(nlFT_selectChannels_bankswanted)
  nameiswanted = false;
  for pidx = 1:length(nlFT_selectChannels_bankswanted)
    thispattern = nlFT_selectChannels_bankswanted{pidx};
    matchlist = regexp(bankname, thispattern);
    if ~isempty(matchlist)
      nameiswanted = true;
    end
  end
end


iswanted = typeiswanted & nameiswanted;


% Done.

end


%
% This is the end of the file.
