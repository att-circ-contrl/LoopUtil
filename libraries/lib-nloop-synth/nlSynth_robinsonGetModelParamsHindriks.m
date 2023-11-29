function [ modelparams intcouplings ] = ...
  nlSynth_robinsonGetModelParamsHindriks()

% function [ modelparams intcouplings ] = ...
%   nlSynth_robinsonGetModelParamsHindriks()
%
% This returns model and coupling parameters for use with
% nlSynth_robinsonStepCortexThalamus() and related functions.
%
% Values are the ones used in Hindriks 2023:
% https://www.nature.com/articles/s42003-023-04648-x
% https://github.com/Prejaas/amplitudecoupling
%
% These are identical to the Robinson 2002 values, except with a smaller
% noise coupling coefficient.
%
% No arguments.
%
% "modelparams" is a model parameter structure with the fields described
%   in MODELPARAMSROBINSON.txt.
% "intcouplings" is a 4x4 matrix indexed by (destination,source) that
%   provides the coupling weights (in mV*s) between excitatory, inhibitory,
%   specific nucleus, and reticular nucleus neurons.


modelparams = struct();

% Paramters for converting potentials to firing rates (sigmoid parameters).
modelparams.qmax = 250;         % 1/sec
modelparams.threshlevel = 15;   % mV
modelparams.threshsigma = 6;    % mV

% Parameters for neural population dynamics (second order DE weights).
modelparams.alpha = 50;    % 1/sec
modelparams.beta = 200;    % 1/sec
modelparams.gamma = 100;   % 1/sec

% Parameters for cortico-thalamic circuit dynamics.
modelparams.halfdelay = 40;  % ms

% Noise parameters.
% FIXME - These are poorly documented and were varied during testing.
modelparams.noisemean = 0.5;
modelparams.noisesigma = 0.1;
modelparams.noisemultfactor = 0.64;   % No idea; assuming per Freyer.


% Internal coupling parameters.

intcouplings = ...
[ 1.2 -1.8 1.2  0 ; ...
  1.2 -1.8 1.2  0 ; ...
  1.2  0   0   -0.8 ; ...
  0.4  0   0.2  0 ];


% Additional coupling parameters.
% Noise couples to the specific nucleus, population mixtures to excitatory
% cortical neurons.

modelparams.noisecoupling = 0.5;
modelparams.mixturecoupling = 0.84;


% Done.
end


%
% This is the end of the file.
