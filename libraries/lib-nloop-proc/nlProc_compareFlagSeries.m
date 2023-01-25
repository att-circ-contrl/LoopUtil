function [ message fp tp fn ] = ...
  nlProc_compareFlagSeries( testflags, correctflags )

% function [ message fp tp fn ] = ...
%   nlProc_compareFlagSeries( testflags, correctflags )
%
% This function compares two boolean signals' time series, computing
% confusion matrix statistics and generating a report.
%
% "testflags" is a vector of boolean values to evaluate.
% "correctflags" is a vector of boolean values representing ground truth for
%   the test series.
%
% "message" is a chacacter array containing a human-readable summary of the
%   confusion matrix statistics.
% "fp" is the number of false-positive samples (test without correct).
% "tp" is the number of true-positive samples (test and correct together).
% "fn" is the number of false-negative samples (correct without test).


% Get the raw confusion matrix counts.
% Tolerate mismatched vectors and empty vectors.

fp = 0;
tp = 0;
fn = 0;

if (length(testflags) > 0) && (length(correctflags) > 0)
  sampcount = min( length(testflags), length(correctflags) );
  testflags = testflags(1:sampcount);
  correctflags = correctflags(1:sampcount);

  testcount = sum(testflags);
  correctcount = sum(correctflags);

  tp = sum(testflags & correctflags);
  fp = testcount - tp;
  fn = correctcount - tp;
end


% Summarize the results, in terms of _relative_ rates.

message = '';

if testcount > 0
  message = [ message sprintf( '%.1f %% of reported positives good.', ...
    100 * tp/testcount ) ];
else
  message = [ message 'No test samples.' ];
end

message = [ message ' ' ];

if correctcount > 0
  message = [ message sprintf( '%.1f %% of ground truth detected.', ...
    100 * tp/correctcount ) ];
else
  message = [ message 'No ground truth samples.' ];
end


% Done.

end


%
% This is the end of the file.
