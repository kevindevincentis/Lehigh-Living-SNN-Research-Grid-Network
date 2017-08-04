% Kevin DeVincentis
% evaluates the response from a trained neural network
% User inputs the cluster centers to be used, the distance method,
% and post-trained data points

warning('off', 'Octave:broadcast')% turn off a specific warning
args = argv();
center_source = args{1};
distance = args{2};
new_data_source = args{3};


% Load the results
results = load(center_source);
bestCenters = results.bestCenters;
newData = load(new_data_source);
newData = newData.results;
% Compile all new data into one matrix
allNewData = [cell2mat(newData(1)); cell2mat(newData(2)); cell2mat(newData(3));
cell2mat(newData(4)); cell2mat(newData(5)); cell2mat(newData(6)); cell2mat(newData(7));
cell2mat(newData(8)); cell2mat(newData(9)); cell2mat(newData(10))];

[bestIdx, bestDist] = getDist(allNewData, bestCenters, distance);

K = 15;
cluster_assignments = zeros(1,10);
lastEnd = 0;
actualDigit = 0;
totalAcc = 0;
totalPoints = 0;
for digit = newData
    digit = cell2mat(digit);
    [h, w] = size(digit);
    counts = zeros(K, 1);

    for i = lastEnd+1:lastEnd+h
        counts(bestIdx(i)) = counts(bestIdx(i)) + 1;
    end
    winner = actualDigit + 1;

    accuracy = counts(winner)/sum(counts) * 100;
    totalPoints = totalPoints + sum(counts);
    totalAcc = totalAcc + counts(winner);

    printf('Digit %d, Assigned Cluster: %d, Accuracy: %d%%\n', actualDigit, winner, accuracy);
    lastEnd = lastEnd+h;
    actualDigit = actualDigit + 1;
end

printf('Total Correct: %d%%\n', totalAcc/totalPoints * 100);
