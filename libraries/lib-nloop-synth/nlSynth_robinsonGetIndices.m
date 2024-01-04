function indices_lut = nlSynth_robinsonGetIndices()

% function indices_lut = nlSynth_robinsonGetIndices()
%
% This returns the row/column indices corresponding to each region simulated
% by the Robinson 2002 model.
%
% No arguments.
%
% "indices_lut" is a structure with the following fields:
%   "cortex_excitatory" is the row/column index corresponding to excitatory
%     neurons in the cortex.
%   "cortex_inhibitory" is the row/column index corresponding to inhibitory
%     neurons in the cortex.
%   "thalamus_specific" is the row/column index corresponding to "specific
%     nucleus" neurons in the thalamus (also called the relay population).
%   "thalamus_reticular" is the row/column index corresponding to "reticular
%     nucleus" neurons in the thalamus.


indices_lut = struct();

indices_lut.cortex_excitatory = 1;
indices_lut.cortex_inhibitory = 2;
indices_lut.thalamus_specific = 3;
indices_lut.thalamus_reticular = 4;


% Done.
end


%
% This is the end of the file.
