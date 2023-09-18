function newtrials = nlFT_sumTrialArrays( ...
  firsttrials, firstweight, secondtrials, secondweight )

% function newtrials = nlFT_sumTrialArrays( ...
%   firsttrials, firstweight, secondtrials, secondweight )
%
% This walks through two "trial" cell arrays (from ft_datatype_raw) and
% computes a weighted sum of correspnding trial matrices. Corresponding
% trial matrices must have the same dimensions.
%
% Among other things, this is intended to be used to add or subtract
% curve fits or background fits from trial data. For example:
%
%  foodata.trial = nlFT_sumTrialArrays(foodata.trial, 1, bgtrials, -1);
%
% "firsttrials" is a cell array containing trial matrices.
% "firstweight" is the weight to apply to trials in "firstrials".
% "secondtrials" is a cell array containing trial matrices.
% "secondweight" is the weight to apply to trials in "secondtrials".
%
% "newtrials" is a cell array containing trial matrices that are a weighted
%   sum of the trials in "firsttrials" and "secondtrials".

newtrials = firsttrials;

firstcount = length(firsttrials);
secondcount = length(secondtrials);

if secondcount ~= firstcount
  disp('### [nlFT_sumTrialArrays]  Different numbers of trials!');
else

  for tidx = 1:firstcount
    thisfirst = firsttrials{tidx};
    thissecond = secondtrials{tidx};

    if ~all( size(thisfirst) == size(thissecond) )
      disp(sprintf( [ '### [nlFT_sumTrialArrays]  ' ...
        'Trial %d has different dimensions!' ], tidx ));
    else
      newtrials{tidx} = firstweight * thisfirst + secondweight * thissecond;
    end
  end

end


% Done.
end


%
% This is the end of the file.
