% Kevin DeVincentis
% Clusters data points and identfies best cluster based on some metrics
% Saves the results in a filen specified by the user
pkg load statistics

args = argv();
filename = args{1};

tic()
results = load('cluster_data.mat');
results = results.results;
% Structure incoming data to NXD matrix, each row is a data point
data = [cell2mat(results(1)); cell2mat(results(2)); cell2mat(results(3));
cell2mat(results(4)); cell2mat(results(5)); cell2mat(results(6)); cell2mat(results(7));
cell2mat(results(8)); cell2mat(results(9)); cell2mat(results(10))];

% Use kmeans function to find the clusters
% Run several times to find optimal result
K = 15; % Number of clusters to look for
bestCluster = 0;
for j = 1:1
    [idx, centers, sumd, dist] = myKmeans(data, K);
    lastEnd = 0;
    actualDigit = 0;
    allWinners = [];
    winnersCount = 0;
    allAccuracy = zeros(10,1);
    cluster_assignments = zeros(1, 10);
    % Analyze how well the clusters correlate to the digits
    for digit = results
        digit = cell2mat(digit);
        [h, w] = size(digit);
        counts = zeros(K, 1);

        for i = lastEnd+1:lastEnd+h
            counts(idx(i)) = counts(idx(i)) + 1;
        end
        [~, winner] = max(counts);
        if (~ismember(winner, allWinners))
            winnersCount = winnersCount + 1;
        end
        allWinners = [allWinners, winner];

        accuracy = counts(winner)/sum(counts) * 100;
        allAccuracy(actualDigit + 1) = accuracy;
        cluster_assignments(actualDigit + 1) = winner;
        lastEnd = lastEnd+h;
        actualDigit = actualDigit + 1;
    end

    % Pick the best one
    if (winnersCount >= 10 && mean(allAccuracy) > bestCluster)
        bestCluster = mean(allAccuracy);
        bestIdx = idx;
        bestCenters = centers;
        bestSumd = sumd;
        bestDist = dist;
    end
end

% Print out relevant information
lastEnd = 0;
actualDigit = 0;
for digit = results
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

bestCenters = bestCenters >= 0.5;
bestCenters = bestCenters(cluster_assignments, :);

% Re-evaluate idices
[bestIdx, bestDist] = getDist(data, bestCenters);
% Save the results
save('-mat-binary', filename, 'bestIdx', 'bestCenters', 'bestSumd', 'bestDist');

toc()
