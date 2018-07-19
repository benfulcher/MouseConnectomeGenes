function ProbabilityConnectionDist(C,doReciprocal,justCortex,makeNewFigure)
% Plots the probability of a connection with spatial distance
% ------------------------------------------------------------------------------
% Ben Fulcher, 2014-10-14
% ------------------------------------------------------------------------------

if nargin < 2
    doReciprocal = false;
end
if nargin < 3
    justCortex = false;
end
if nargin < 4
    makeNewFigure = true;
end

% ------------------------------------------------------------------------------
% Set parameters:
% ------------------------------------------------------------------------------

analyzeWhat = 'distance';

pThresh = 0.05;

numThresholds = 20;

% ------------------------------------------------------------------------------
% Get data and compute:

% 1. Pairwise distances
distAll = C.Dist_Matrix{1}/1000;

% 2. Link information:
Adj = GiveMeAdj(C,'binary','ipsi',0,pThresh);
if doReciprocal
    linkData = AdjLabelLinks('reciprocal',Adj);
else
    linkData = Adj;
end
clear Adj

% Filter is just cortex:
if justCortex
    isCortex = strcmp({C.RegionStruct.MajorRegionName},'Isocortex');
    distAll = distAll(isCortex,isCortex);
    linkData = linkData(isCortex,isCortex);
end

numNodes = length(linkData);

%-------------------------------------------------------------------------------
% Organize into bins:
[distGroups,countConns,binMeans] = doQuantiling(linkData,distAll,doReciprocal);

% ------------------------------------------------------------------------------
% Plot:
if makeNewFigure
    f = figure('color','w'); box('on'); hold on
else
    f = gcf; box('on'); hold on
end

myColors = BF_getcmap('set1',4,1);
theColor = 'k';
theStyle = '-';

% Mean +/- std:
for k = 1:numThresholds-1
    plot(binMeans(k),countConns(k),'o','MarkerSize',5,'LineStyle',theStyle,'LineWidth',1.5,'Color',theColor)
    plot(distGroups(k:k+1),ones(2,1)*countConns(k),'LineStyle',theStyle,'LineWidth',1.5,'Color',theColor)
end

if doReciprocal
    ylabel('Reciprocal connection probability, {\it p_r}')
else
    ylabel('Connection probability, {\it p}')
end

xlabel('Distance, {\it d} (mm)')


% Add a fitted line
% Ben Fulcher, 2015-02-02
[f_handle,Stats,c] = GiveMeFit(binMeans',countConns','exp0',1);
xData = linspace(0,max(distAll(:)),50);
plot(xData,f_handle(xData),':k');

fprintf(1,'Fit to f(x) = %.3f exp(-%.3f x)\n',c.A,c.n);

% Add the fit assuming independence:
% (from Francis): p^2 / (1 - (1-p)^2).
if doReciprocal
    Adj = GiveMeAdj(C,'binary','ipsi',justCortex,pThresh);
    Adj = (Adj | Adj');
    [distGroups,countConns_conn,binMeans_conn] = doQuantiling(Adj,distAll,0);
    % [~,Stats,c] = GiveMeFit(binMeans_conn',countConns_conn','exp0',1);
    f_independence = @(p) p.^2/(1-(1-p).^2);
    colors = BF_getcmap('set1',5,1);
    plot(binMeans_conn,arrayfun(f_independence,countConns_conn),'x','color',colors{2});
end

%-------------------------------------------------------------------------------
if makeNewFigure
    f.Position = [280   631   288   198];
end
ax = gca;
if justCortex
    title(sprintf('Cortex only (%ux%u)',numNodes,numNodes))
else
    title(sprintf('Whole brain (%ux%u)',numNodes,numNodes))
    ax.XLim = [0,13];
end

%-------------------------------------------------------------------------------
function [distGroups,countConns,binMeans] = doQuantiling(linkData,distAll,doReciprocal)

    distGroups = arrayfun(@(x)quantile(distAll(distAll>0),x),linspace(0,1,numThresholds));

    if doReciprocal
        % proportion of links that exist that are reciprocal
        % countConns = arrayfun(@(x)sum(linkData(distAll>=distGroups(x) & distAll < distGroups(x+1))==1) ...
                            % /sum(Adj(distAll>=distGroups(x) & distAll < distGroups(x+1))),1:numThresholds-1);
        countConns = arrayfun(@(x)sum(linkData(distAll>=distGroups(x) & distAll < distGroups(x+1))==1) ...
                            /sum(linkData(distAll>=distGroups(x) & distAll < distGroups(x+1))>0),1:numThresholds-1);
    else
        countConns = arrayfun(@(x)mean(linkData(distAll>=distGroups(x) & distAll < distGroups(x+1))),1:numThresholds-1);
    end

    binMeans = mean([distGroups(1:end-1);distGroups(2:end)]);

end

end
