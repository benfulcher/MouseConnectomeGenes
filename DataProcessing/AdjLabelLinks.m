% ------------------------------------------------------------------------------
% Ben Fulcher, 2014-10-01
% ------------------------------------------------------------------------------

function [linkLabels, classNames] = AdjLabelLinks(labelWhat,Adj,extraParam)

numNodes = length(Adj);


switch labelWhat

    case 'reciprocal'
        % Return reciprocal links (1), unidirectional (2)
        isReciprocal = (Adj==1 & Adj'==1);
        linkLabels = zeros(size(isReciprocal));
        linkLabels(isReciprocal) = 1;
        linkLabels(Adj==1 & ~isReciprocal) = 2;
        classNames = {'reciprocal','non-reciprocal'};

    case {'hub-topN','hub-kth'}
        % Code:
        % 1. hub-hub (rich) links
        % 2. hub-nothub (feed-out) links
        % 3. nothub-hub (feed-in) links
        % 4. nothub-nothub (local) links

        switch labelWhat
        case 'hub-topN'
            % Count the top x nodes as hubs
            if nargin < 3
                % Determine hubs as top 20 based on degree
                extraParam = {'degree',20};
            end
        case 'hub-kth'
            if nargin < 3
                % Determine hubs as top 20 based on degree
                extraParam = {'degree',50};
            end
        end

        % Label all nodes as hubs or not:
        isHub = AdjLabelNodes(labelWhat,Adj,extraParam) - 1;

        % Make source/target indicator matrices:
        nodeSource = repmat(isHub,1,numNodes);
        nodeTarget = repmat(isHub',numNodes,1);

        % Assign labels to all links:
        linkLabels = zeros(numNodes);
        % hub-hub -> 1
        linkLabels(nodeSource==1 & nodeTarget==1) = 1;
        % hub-nothub -> 2
        linkLabels(nodeSource==1 & nodeTarget==0) = 2;
        % % nothub-hub -> 3
        linkLabels(nodeSource==0 & nodeTarget==1) = 3;
        % nothub-nothub -> 4
        linkLabels(nodeSource==0 & nodeTarget==0) = 4;

        linkLabels(Adj==0) = 0;

        % Remove diagonal entries:
        linkLabels(logical(eye(size(linkLabels)))) = 0;

        classNames = {sprintf('Rich (%u)',sum(linkLabels(:)==1)),...
                        sprintf('Feed-out (%u)',sum(linkLabels(:)==2)),...
                        sprintf('Feed-in (%u)',sum(linkLabels(:)==3)),...
                        sprintf('Local (%u)',sum(linkLabels(:)==4))};

end
