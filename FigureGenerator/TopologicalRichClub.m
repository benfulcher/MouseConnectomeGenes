% Ben Fulcher, 2015-02-26

close all

%-------------------------------------------------------------------------------
% Rich club linked PLUS distance:
%-------------------------------------------------------------------------------
PlotRichClubLinked(C,CDM,'bd',0.05,1);
title('') % remove title
subplot(6,1,1:2); title(''); % remove the title
RichClub(C,G,CDM,'distance',1);
title('') % remove title
box('off')
SaveAllFigures(sprintf('richclub_together_again'),'eps',0);

% ------------------------------------------------------------------------------
% Rich Club Linked
% ------------------------------------------------------------------------------
PlotRichClubLinked(C,CDM,'bd',0.05,1);
title('') % remove title
LabelCurrentAxes('A',gca,26,'topRight')
subplot(6,1,1:2); title(''); % remove the title
SaveAllFigures(sprintf('richclub_coeff'),'eps',0);

% ------------------------------------------------------------------------------
% Rich club properties:
% ------------------------------------------------------------------------------
analyzeWhats = {'propReciprocal','distance','weight','edgeBetweenness','communicability'};
subplotLabels = {'C','D','E','F','G'};
plotJustRich = 1;

for i = 1:length(analyzeWhats)
    RichClub(C,G,CDM,analyzeWhats{i},plotJustRich);
    title('') % remove title
    box('off')

    LabelCurrentAxes(subplotLabels{i},gca,24,'topRight')

    if i < 3
        xlabel(''); % don't show x-label
    end

    SaveAllFigures(sprintf('richclub_%s',analyzeWhats{i}),'eps',0);
end

% ------------------------------------------------------------------------------
% Edge betweenness and communicability together
% ------------------------------------------------------------------------------
