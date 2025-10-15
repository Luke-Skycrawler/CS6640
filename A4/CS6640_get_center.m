function [ROI,r1,r2,c1,c2] = CS6640_get_center(im)
% CS6640_get_center - get center ROI of bottles image
% On inut:
%     im (MxNx3 array): RGB image
% On output:
%     ROI (hxwx3 array): center part of image
%     r1 (int): first row of ROI in im
%     r2 (int): last row of ROI in im
%     c1 (int): first col of ROI in im
%     c2 (int): first col of ROI in im
% Call:
%     [ROI,r1,r2,c1,c2] = CS6640_get_center(im001);
% Author:
%     T. Henderson
%     UU
%     Fall 2025
%

MIN_WIDTH = 35;
MEAN_CTR_COL = 180;
MAX_CTR_DIST = 30;

% default if no center found
ROI = im;
r1 = 1;
r2 = 288;
c1 = 180-60;;
c2 = 180+60;

img = double(im(:,:,3)<100);
row25 = img(25,:);
cols = find(row25);
min_col = min(cols);
max_col = max(cols);
tv = [min_col:max_col];
len_tv = length(tv);
found = 0;
ctrs = zeros(len_tv,3);
for t = 1:len_tv
    row25_cc = bwlabel(row25);
    num_cc = max(row25_cc);
    for cc = 1:num_cc
        indexes = find(row25_cc==cc);
        if length(indexes)<MIN_WIDTH
            row25_cc(indexes) = 0;
        end
    end
    row25_cc = bwlabel(row25_cc);
    num_cc = max(row25_cc);
    ind = zeros(num_cc,1);
    if num_cc>0&num_cc<4
        for cc = 1:num_cc
            cols = find(row25_cc==cc);
            if length(cols)>MIN_WIDTH
                ind(cc) = ceil(mean(cols));
            end
        end
        ctrs(t,1:num_cc) = ind';
    end
end
final_centers = mode(ctrs);
indexes = find(final_centers>0);
num_indexes = length(indexes);
if num_indexes==0
    return
end
actual_ctr = 0;
for k = 1:num_indexes
    if abs(final_centers(k)-MEAN_CTR_COL)<MAX_CTR_DIST
        actual_ctr = final_centers(k);
    end
end
if actual_ctr>0
    c1 = actual_ctr - 60;
    c2 = actual_ctr + 60;
end
ROI = im(r1:r2,c1:c2,:);

tch = 0;
