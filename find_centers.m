% Kevin DeVincentis
% Find the center for group of data points associated with the same digit
% No Kmeans clustering is used.
% Supports Hamming Distance and Overlap Distance
% Arg 1 is the source of the data, arg 2 is the distance, arg 3 is the output file name

args = argv();
source = args{1};
distance = args{2};
filename = args{3};
W = 30;

results = load(source);
results = results.results;
numDigits = size(results, 2);
D = size(cell2mat(results(1)), 2);

bestCenters = zeros(numDigits, D);
for i = 1:numDigits
    data = cell2mat(results(i));

    if (lower(distance) == 'hamming')
        tot = size(data, 1);
        sums = sum(data, 1);
        bestCenters(i, :) = (sums./tot) > 0.5;
    end

    if (lower(distance) == 'overlap')
        tot = size(data, 1);
        sums = sum(data, 1);
        [rankedSums, idxSums] = sort((sums./tot), 'descend');
        limit = min(size(rankedSums,2), W);
        acceptedOnes = find(rankedSums(1:limit) >= 0.7);
        acceptedIdxs = idxSums(acceptedOnes);
        bestCenters(i, :) = zeros(1, D);
        bestCenters(i, acceptedIdxs) = 1;
    end

end

data = [cell2mat(results(1)); cell2mat(results(2)); cell2mat(results(3));
cell2mat(results(4)); cell2mat(results(5)); cell2mat(results(6)); cell2mat(results(7));
cell2mat(results(8)); cell2mat(results(9)); cell2mat(results(10))];

[bestIdx, bestDist] = getDist(data, bestCenters, distance);

save('-mat-binary', filename, 'bestIdx', 'bestCenters', 'bestDist');
