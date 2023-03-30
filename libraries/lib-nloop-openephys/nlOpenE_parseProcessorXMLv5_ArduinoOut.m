function newmeta = nlOpenE_parseProcessorXMLv5_ArduinoOut( ...
  oldmeta, xmlproc, xmleditor )

% function newmeta = nlOpenE_parseProcessorXMLv5_ArduinoOut( ...
%   oldmeta, xmlproc, xmleditor )
%
% This parses an Open Ephys v0.5 XML processor node configuration tag for
% an Arduino Output node, and adds type-specific metadata to the supplied
% metadata structure.
%
% "oldmeta" is the metadata structure built by the "entry point" function.
%   It contains the "common" metadata described in PROCMETA_OPENEPHYSv5.txt.
% "xmlproc" is a structure containing the XML parse tree (per readstruct())
%   of the "processor" tag being interpreted.
% "xmleditor" is a structure containing the XML parse tree of the "editor"
%   tag within the "processor" tag, or struct([]) if none was found.
%
% "newmeta" is a copy of "oldmeta" augmented with plugin-specific metadata.


% NOTE - Assume everything we need is here (no bulletproofing).


% Copy the existing metadata.
newmeta = oldmeta;


% Get raw config.
% TTL channels are saved using descriptive names, which we'll have to parse.

newmeta.inputpretty = char( xmleditor.('InputChannelAttribute') );
newmeta.gatepretty = char( xmleditor.('GateChannelAttribute') );
newmeta.ardoutput = xmleditor.('OutputChannelAttribute');
newmeta.serialdev = char( xmleditor.('DeviceAttribute') );


% Translate the pretty names. "bogus" translates to "NaN".

[ thisbank thisbit thisname ] = helper_parsePrettyName(newmeta.inputpretty);
newmeta.inputbank = thisbank;
newmeta.inputbit = thisbit;
newmeta.inputlabel = thisname;

[ thisbank thisbit thisname ] = helper_parsePrettyName(newmeta.gatepretty);
newmeta.gatebank = thisbank;
newmeta.gatebit = thisbit;
newmeta.gatelabel = thisname;


% Generate config descriptions.

thismsg = sprintf( '.. Node %d is an Arduino output ("%s", D%d output).', ...
  newmeta.procnode, newmeta.serialdev, newmeta.ardoutput );
newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];

thismsg = '   Listening to TTL ';
if isnan(newmeta.inputbank)
  thismsg = [ thismsg '(none)' ];
else
  thismsg = [ thismsg sprintf( '%d:%d ("%s")', ...
    newmeta.inputbank, newmeta.inputbit, newmeta.inputlabel ) ];
end
thismsg = [ thismsg ' gated by ' ];
if isnan(newmeta.gatebank)
  thismsg = [ thismsg '(none)' ];
else
%  thismsg = [ thismsg newmeta.gatepretty ];
  thismsg = [ thismsg sprintf( '%d:%d ("%s")', ...
    newmeta.gatebank, newmeta.gatebit, newmeta.gatelabel ) ];
end
thismsg = [ thismsg '.' ];

newmeta.descsummary = [ newmeta.descsummary { thismsg } ];
newmeta.descdetailed = [ newmeta.descdetailed { thismsg } ];

% Done.
end


%
% Helper Functions


% This parses a name of the form "A:B (xxx)", handling the "bogus" case.

function [ bankidx bitidx banklabel ] = helper_parsePrettyName(thisname)

  bankidx = NaN;
  bitidx = NaN;
  banklabel = 'none';

  tokenlist = regexp(thisname, '(\d+):(\d+)\s*\((.*)\)', 'tokens');

  if ~isempty(tokenlist)
    bankidx = str2num(tokenlist{1}{1});
    bitidx = str2num(tokenlist{1}{2});
    banklabel = tokenlist{1}{3};
  end

end


%
% This is the end of the file.
