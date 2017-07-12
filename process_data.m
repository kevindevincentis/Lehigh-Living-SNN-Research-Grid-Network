pkg load statistics
results = load('cluster_data.mat');
results = results.results;
% Structure incoming data to NXD matrix, each row is a data point
data = [cell2mat(results(1)); cell2mat(results(2)); cell2mat(results(3));
cell2mat(results(4)); cell2mat(results(5)); cell2mat(results(6)); cell2mat(results(7));
cell2mat(results(8)); cell2mat(results(9)); cell2mat(results(10))];

% Use kmeans function to find the clusters
K = 10;
[idx, centers, sumd, dist] = kmeans(data, K, 'EmptyAction', 'singleton', 'Distance', 'Hamming', 'Start', 'plus');
idx
% Determine if clusters match the input digits
% How good are these clusters
lastEnd = 0;
actualDigit = 0;
for digit = results
    digit = cell2mat(digit);
    [h, w] = size(digit);
    counts = zeros(10, 1);

    for i = lastEnd+1:lastEnd+h
        counts(idx(i)) = counts(idx(i)) + 1;
    end
    [~, winner] = max(counts);
    printf('Digit %d, Assigned Cluster: %d, Accuracy: %d%%, Size: %d\n', actualDigit, winner, counts(winner)/sum(counts) * 100, sum(dist(:, winner)));
    lastEnd = lastEnd+h;
    actualDigit = actualDigit + 1;
end
