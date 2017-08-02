% Kevin DeVincentis
% evaluates the response from a trained neural network
% User inputs the clusters to be used, the pre-trained data points,
% and post-trained data points

warning('off', 'Octave:broadcast')% turn off a specific warning
args = argv();
cluster_source = args{1};
data_source = args{2};
new_data_source = args{3};


% Load the results
results = load(cluster_source);
bestIdx = results.bestIdx;
bestDist = results.bestDist;
bestCenters = results.bestCenters;
data = load(data_source);
data = data.results;
newData = load(new_data_source);
newData = newData.results;

K = 15
cluster_assignments = zeros(1,10);
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
    cluster_assignments(actualDigit + 1) = winner;
    lastEnd = lastEnd+h;
    actualDigit = actualDigit + 1;
end

% Compile all new data into one matrix
allNewData = [cell2mat(newData(1)); cell2mat(newData(2)); cell2mat(newData(3));
cell2mat(newData(4)); cell2mat(newData(5)); cell2mat(newData(6)); cell2mat(newData(7));
cell2mat(newData(8)); cell2mat(newData(9)); cell2mat(newData(10))];

% Find the accuracies with the new data
newDist = zeros(size(allNewData, 1), size(bestCenters, 1));
newIdx = zeros(size(allNewData, 1), 1);
for row = 1:size(allNewData, 1)
    dataPoint = allNewData(row, :);
    d = sum(dataPoint ~= bestCenters, 2)';
    newDist(row, :) = d;
    [~, newIdx(row, 1)] = min(d);
end

actualDigit = 0;
lastEnd = 0;

cluster_assignments
for digit = newData
    digit = cell2mat(digit);
    [h, w] = size(digit);
    counts = zeros(K, 1);

    for i = lastEnd+1:lastEnd+h
        counts(newIdx(i)) = counts(newIdx(i)) + 1;
    end
    winner = actualDigit + 1;

    accuracy = counts(winner)/sum(counts) * 100;

    % Size is the distance from the cluster to its furthest member
    possibilities = find((newIdx == winner));
    rad = max(newDist(possibilities, winner));
    printf('Digit %d, Assigned Cluster: %d, Accuracy: %d%%, Size: %d\n', actualDigit, winner, accuracy, rad);
    lastEnd = lastEnd+h;
    actualDigit = actualDigit + 1;
end
