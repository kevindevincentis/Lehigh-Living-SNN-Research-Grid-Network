pkg load statistics
tic()
results = load('cluster_data.mat');
results = results.results;
% Structure incoming data to NXD matrix, each row is a data point
data = [cell2mat(results(1)); cell2mat(results(2)); cell2mat(results(3));
cell2mat(results(4)); cell2mat(results(5)); cell2mat(results(6)); cell2mat(results(7));
cell2mat(results(8)); cell2mat(results(9)); cell2mat(results(10))];

% Use kmeans function to find the clusters
% Run several times to find optimal result
K = 15;
bestCluster = 0;
for j = 1:100
    [idx, centers, sumd, dist] = kmeans(data, K, 'EmptyAction', 'singleton', 'Distance', 'Hamming', 'Start', 'plus');
    lastEnd = 0;
    actualDigit = 0;
    allWinners = [];
    winnersCount = 0;
    allAccuracy = zeros(10,1);
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
    printf('Digit %d, Assigned Cluster: %d, Accuracy: %d%%, Size: %d\n', actualDigit, winner, accuracy, sum(bestDist(:, winner)));
    lastEnd = lastEnd+h;
    actualDigit = actualDigit + 1;
end

% Save the results
save('-mat-binary', 'cluster_results.mat', 'bestIdx', 'bestCenters', 'bestSumd', 'bestDist');

toc()
