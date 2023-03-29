function metalist = nlOpenE_parseProcessorNodesXML_v5( xmlstructlist )

% function metalist = nlOpenE_parseProcessorNodesXML_v5( xmlstructlist )
%
% This parses a series of Open Ephys v0.5 XML processor node configuration
% tags, extracting configuration metadata from each of them.
%
% "xmlstruct" is a cell array containing structures. Each structure contains
%   the XML parse tree (per readstruct()) from one "processor" tag from an
%   Open Ephys v0.5 configuration file.
%   NOTE - This cell array is what you'd get from looking for 'processor'
%   tags using nlUtil_findXMLStructNodesRecursing().
%
% "metalist" is a cell array with one entry per entry in xmlstructlist. Each
%   entry is a processor node metadata structure containing configuration
%   information in the format described in PROCMETA_OPENEPHYSv5.txt.


metalist = {};

% Iterate through the list and call the generic parsing entry point function.

for pidx = 1:length(xmlstructlist)
  thisproc = xmlstructlist{pidx};
  metalist{pidx} = nlOpenE_parseProcessorXMLv5_Entrypoint( thisproc );
end


% Done.
end


%
% This is the end of the file.
