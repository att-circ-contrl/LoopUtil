function metalist = nlOpenE_parseConfigProcessorsXML_v5( xmlconfigstruct )

% function metalist = nlOpenE_parseConfigProcessorsXML_v5( xmlconfigstruct )
%
% This searches an XML configuration parse tree for processor nodes, and
% attempts to extract configuration metadata for each of them.
%
% "xmlconfigustruct" is a structure containing an XML parse tree of an
%   Open Ephys v0.5 config file, as returned by readstruct().
%
% "metalist" is a cell array with one entry per processor node found. Each
%   entry is a processor node metadata structure containing configuration
%   information in the format described in PROCMETA_OPENEPHYSv5.txt.


metalist = {};

% Find all processor nodes in the config tree.
proclist = ...
  nlUtil_findXMLStructNodesRecursing( xmlconfigstruct, { 'processor' }, {} );

% Iterate through the list and call the generic parsing entry point function.
for pidx = 1:length(proclist)
  metalist{pidx} = nlOpenE_parseProcessorNodeXML_v5( proclist{pidx} );
end


% Done.
end


%
% This is the end of the file.
