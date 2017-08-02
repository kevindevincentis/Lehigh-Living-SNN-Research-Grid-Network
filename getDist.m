function [idx, dist] = getDist(data, centers)
    K = size(centers, 1);
    numPoints = size(data,1);
    dist = zeros(numPoints, K);
    for row = 1:numPoints
        dataPoint = data(row, :);
        d = sum((dataPoint & centers), 2)';
        dist(row, :) = d;
        % Assign each data point to a cluster
        [~, idx(row, 1)] = max(d);
    end
end
