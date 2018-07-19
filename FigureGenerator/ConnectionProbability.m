% Idea that all my figures should be coded
% Easy to do if you make scripts like this, that combine various analysis tools
% ------------------------------------------------------------------------------
% Ben Fulcher, 2015-02-26
% ------------------------------------------------------------------------------

f = figure('color','w'); box('on');

subplot(1,2,1)
ProbabilityConnectionDist(C,0,0,0);
LabelCurrentAxes('a',gca,20,'topRight')
subplot(1,2,2)
ProbabilityConnectionDist(C,1,1,0);
LabelCurrentAxes('b',gca,20,'topRight')

f.Position = [1295,756,544,217];
