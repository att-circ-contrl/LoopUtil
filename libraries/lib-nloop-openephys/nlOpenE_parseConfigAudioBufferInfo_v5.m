function audiometa = nlOpenE_parseConfigAudioBufferInfo_v5( xmlconfigstruct )

% function audiometa = nlOpenE_parseConfigAudioBufferInfo_v5( xmlconfigstruct )
%
% This searches an XML configuration parse tree for an "Audio" tag,
% and extracts audio buffer information from it.
%
% "xmlconfigstruct" is a structure containing an XML parse tree of an
%   Open Ephys v0.5 config file, as returned by readstruct().
%
% "audiometa" is a structure with the following fields:
%   "samprate" is the audio sampling rate.
%   "bufsamps" is the length of the audio buffer in samples.
%   "bufms" is the length of the audio buffer in milliseconds. This is
%     the polling rate for Open Ephys signal chain updates.


audiometa = struct( 'samprate', NaN, 'bufsamps', NaN, 'bufms', NaN );

taglist = ...
  nlUtil_findXMLStructNodesRecursing( xmlconfigstruct, { 'audio' }, {} );


% Look for an "audio" tag that has a "devicesetup" tag inside it.
% This should catch and ignore anything else named "audio" that people
% decided to include inside signal chain nodes.

found = false;

for tidx = 1:length(taglist)
  if ~found
    thistag = taglist{tidx};

    devtaglist = ...
      nlUtil_findXMLStructNodesTopLevel( thistag, { 'devicesetup' }, {} );

    if ~isempty(devtaglist)
      found = true;

      % Settings are duplicated in "audio" and "devicesetup". Use "audio".
      audiometa.samprate = thistag.('sampleRateAttribute');
      audiometa.bufsamps = thistag.('bufferSizeAttribute');
      audiometa.bufms = audiometa.bufsamps * 1000.0 / audiometa.samprate;
    end
  end
end


% Done.
end


%
% This is the end of the file.
