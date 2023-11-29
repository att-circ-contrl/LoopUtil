function [ modelparams intcouplings noisecouplings ] = ...
  nlSynth_robinsonGetModelParamsRobinson()

% function [ modelparams intcouplings noisecouplings ] = ...
%   nlSynth_robinsonGetModelParamsRobinson()
%
% This returns model and coupling parameters for use with
% nlSynth_robinsonStepCortexThalamus().
%
% Values are the ones used in Robinson 2002 (Table 1):
% https://journals.aps.org/pre/abstract/10.1103/PhysRevE.65.041924
%
% No arguments.
%
% "modelparams" is a model parameter structure with the fields described
%   in nlSynth_robinsonStepCortexThalamus().
% "intcouplings" is a 4x4 matrix indexed by (destination,source) that
%   provides the coupling weights (in mV*s) between excitatory, inhibitory,
%   specific nucleus, and reticular nucleus neurons.
% "noisecouplings" is a 4x1 matrix indexed by destination that provides the
%   coupling weights (in mV*s) from the noise signal to excitatory,
%   inhibitory, specific nucleus, and reticular nucleus neurons.


modelparams = struct();

% Paramters for converting potentials to firing rates (sigmoid parameters).
modelparams.qmax = 250;         % 1/sec
modelparams.threshlevel = 15;   % mV
modelparams.threshsigma = 6;    % mV

% Parameters for neural population dynamics (second order DE weights).
modelparams.alpha = 50;    % 1/sec
modelparams.beta = 200;    % 1/sec
modelparams.gamma = 100;   % 1/sec


% Internal coupling parameters.
% NOTE - Robinson set the inhibitory potential to be equal to the
% excitatory potential, rather than modelling inhibitory neurons separately.
% Freyer 2011 and Hindriks 2023 duplicated the couplings to get the same
% behavior.

intcouplings = ...
[ 1.2 -1.8 1.2  0 ; ...
  1.2 -1.8 1.2  0 ; ...
  1.2  0   0   -0.8 ; ...
  0.4  0   0.2  0 ];

% Noise coupling parameters. Noise only couples to the specific nucleus.

noisecouplings = ...
[ 0 ;
  0 ;
  1.0 ;
  0 ];


% Done.
end


%
% This is the end of the file.
