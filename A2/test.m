function d_gt = test()
d_gt = ground_truth();
[reports, d_inspect, thresholds] = CS6640_inspect('All');

for i = 1: 141
    for j = 1:2
        if d_inspect(i,j) > thresholds(j)
            d_inspect(i,j) = 1;
        else
            d_inspect(i,j) = 0;
        end
        if d_inspect(i, j) ~= d_gt(i, j)
            fprintf('Error in image %d, defect %d, correct = %d\n', i, j, d_gt(i,j));

        end
    end
end