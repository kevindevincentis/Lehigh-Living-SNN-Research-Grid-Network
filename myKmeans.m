% Kevin DeVincentis
% Kmeans algorithm with hamming distance as default but can also use a similarity score



function [idx, centers, sumd, dist] = myKmeans(data, K, W, distance)
    if nargin < 4
        distance = 'hamming';
    end

    warning('off', 'Octave:broadcast');
    iters = 0;
    D = size(data, 2);
    numPoints = size(data, 1);
    % Start with random centers
    centers = rand(K,D) > 0.5;
    oldCenters = zeros(K,D);

    % converge on clusters
    while(sum(sum(oldCenters ~= centers)) > 1)
        oldCenters = centers;

        % Find add distances
        [idx, dist] = getDist(data, centers, distance);

        for i = 1:K
            [row, col] = find(idx == i);
            points = data(row, :);
            tot = size(points, 1);
            if (tot == 0)
                continue
            end
            sums = sum(points, 1);

            if (lower(distance) == 'hamming')
                % Find new centers by taking the median value for each bit
                centers(i, :) = (sums./tot) > 0.5;
            end

            if (lower(distance) == 'overlap')
                % Find new centers by taking the overlap of each cluster
                [rankedSums, idxSums] = sort((sums./tot), 'descend');
                limit = min(size(rankedSums,2), W);
                acceptedOnes = find(rankedSums(1:limit) >= 0.7);
                acceptedIdxs = idxSums(acceptedOnes);
                centers(i, :) = zeros(1, D);
                centers(i, acceptedIdxs) = 1;
            end

        end
        iters = iters + 1;
        if (iters >= 100)
            break;
        end
    end

    [idx, dist] = getDist(data, centers, distance);
    dist(:, 1:K-2);
    sumd = sum(dist);

end
