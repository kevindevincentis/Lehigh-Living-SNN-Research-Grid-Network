% Load the results
results = load('cluster_results.mat');
bestIdx = results.bestIdx;
bestDist = results.bestDist;
bestCenters = results.bestCenters;
data = load('cluster_data.mat');
data = data.results;

K = 15;
lastEnd = 0;
actualDigit = 0;
for digit = data
    digit = cell2mat(digit);
    [h, w] = size(digit);
    counts = zeros(K, 1);

    for i = lastEnd+1:lastEnd+h
        counts(bestIdx(i)) = counts(bestIdx(i)) + 1;
    end
    [~, winner] = max(counts);

    accuracy = counts(winner)/sum(counts) * 100;

    % Size is the distance from the cluster to its furthest member
    possibilities = find((bestIdx == winner));
    rad = max(bestDist(possibilities, winner));
    printf('Digit %d, Assigned Cluster: %d, Accuracy: %d%%, Size: %d\n', actualDigit, winner, accuracy, rad);
    lastEnd = lastEnd+h;
    actualDigit = actualDigit + 1;
end

printf('Distance between centers matrix:')
dist = pdist2(bestCenters, bestCenters, 'hamming');
display(dist);
