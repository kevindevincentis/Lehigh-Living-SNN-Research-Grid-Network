
args = argv();
distance = args{1};
source = args{2};
W = 30;

% Load the results
warning('off', 'Octave:broadcast');
results = load(source);
bestIdx = results.bestIdx;
bestDist = results.bestDist;
if (lower(distance) == 'overlap')
    bestDist = W - bestDist;
end
bestCenters = results.bestCenters;
data = load('cluster_data.mat');
data = data.results;

K = 15;
lastEnd = 0;
actualDigit = 0;
rads = zeros(10,1);
cluster_assignments = zeros(10,1);
totalAcc = 0;
totalPoints = 0;
for digit = data
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

% Find distance between centers
bestCenters = bestCenters >= 0.5;
numCenters = size(bestCenters,1);
[~, dist] = getDist(bestCenters, bestCenters, distance);
if (lower(distance) == 'overlap')
    dist = W - dist;
end
dist
realDist = zeros(45,1);
counter = 1;
for i = 1:numCenters
    for j = i + 1:numCenters
        realDist(counter) = dist(i, j);
        counter = counter + 1;
    end
end

maxCenterDistance = max(max(realDist))
minCenterDistace = min(min(realDist))
avgCenterDistance = mean(mean(realDist))

avgPointDistance = zeros(1, numCenters);
for i = 1:numCenters
    assignedPoints = find(bestIdx == i);
    avgPointDistance(i) = mean(bestDist(assignedPoints, i));
end

avgPointDistance
% Find overlap between clusters
% overlaps = zeros(10,1);
% counter = 1;
% for i = 1:10
%     thresh = rads(i);
%     curDist = bestDist(cluster_assignments(i));
%     to_remove = find((bestIdx == cluster_assignments(i)));
%     dist = bestDist(:, cluster_assignments(i));
%
%     tot = sum(dist <= thresh);
%     dist(to_remove) = thresh + 1;
%     notAssigned = sum(dist <= thresh);
%     overlaps(i) = notAssigned/tot;
% end

% overlaps
% mean(overlaps)
