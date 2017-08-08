function [idx, dist] = getDist(data, centers, distance)
    warning('off', 'Octave:broadcast');

    if nargin < 3
        distance = 'hamming';
    end
    K = size(centers, 1);
    numPoints = size(data,1);
    dist = zeros(numPoints, K);
    for row = 1:numPoints
        dataPoint = data(row, :);
        if (lower(distance) == 'overlap')
            d = sum((dataPoint & centers), 2)';
            minDistFun = 'max';
        end
        if(lower(distance) == 'hamming')
            d = sum((dataPoint ~= centers), 2)';
            minDistFun = 'min';
        end
        dist(row, :) = d;
        % Assign each data point to a cluster

        [~, idx(row, 1)] = feval(minDistFun, d);
    end
end
