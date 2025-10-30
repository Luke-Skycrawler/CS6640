function [report,defects,thresholds] = CS6640_inspect(d_name)
% CS6640_inspect - inspect all images in a directory
% On input:
%     d_name (string): name of directory path
% On output:
%     report (vector struct): info on defects                                                       
%       (k).name (string): image name (with directory path)                                         
%       (k).defects (string): defects of kth image
%     defects (nx8 array): all defects info
%         col 1: underfilled                                                                         
%         col 2: overfilled                                                                        
%         col 3: label missing                                                                      
%         col 4: label white                                                                        
%         col 5: label not straight                                                                 
%         col 6: cap missing                                                                        
%         col 7: bottle deformed                                                                    
%         col 8: no bottle                                                                          
%     thresholds (8x1 vector): probability thresholds for defects
% Call:
%     [report,defects,thresholds] = CS6640_inspect(d_name);
% Author:
%     Haoyang Shi
%     UU
%     Fall 2025
%

thresholds = -ones(8,1);
thresholds(1) = 0.5;
thresholds(2) = 0.5;
thresholds(4) = 0.5;
thresholds(5) = 0.5;
thresholds(6) = 0.5;
thresholds(8) = 0.9;

defect_names(1).defect = 'underfilled';
defect_names(2).defect = 'overfilled';
defect_names(3).defect = 'label missing';
defect_names(4).defect = 'label white';
defect_names(5).defect = 'label not straight';
defect_names(6).defect = 'no cap';
defect_names(7).defect = 'deformed';
defect_names(8).defect = 'no bottle';

list = dir([d_name,'\*.jpg']);
number_of_files = length(list);
for k = 1:number_of_files
    report(k).name = [];
    report(k).defects = [];
end
defects = zeros(number_of_files,8);

for k = 1: number_of_files
    filename = list(k).name;
    report(k).name = [d_name,'\',filename]; %filename;
    I = imread([d_name,'\',filename]);
    d = zeros(1,8);

    % check for no bottle error
    d(8) = CS6640_defect_no_bottle(I);
    d(1) = CS6640_defect_under_filled(I);
    d(2) = CS6640_defect_over_filled(I);
    d(3) = CS6640_defect_label_missing(I);
    d(4) = CS6640_defect_white_label(I);
    d(5) = CS6640_defect_not_straight(I);
    d(6) = CS6640_defect_no_cap(I);
    d(7) = CS6640_defect_deformed(I);

    for j = 1: 8
        if d(j) > thresholds(j)
            report(k).defects = defect_names(j);
        end
    end
    defects(k,:) = d;
end
end

% Defect 1: under-filled
function p = CS6640_defect_under_filled(im)
% CS6640_defect_under_filled - determine if under-filled
% On input:
%     im (MxNx3 array): input image
% On output:
%     p (float): probability under-filled
% Call:
%     b = CS6640_defect_under_filled(bot1);
% Author:
%     Haoyang Shi
%     UU
%     Fall 2025
%

shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(:, round(w / 3):round(w * 2/ 3), :);
gray = im2gray(im_culled);

gx_stencil = zeros(3, 3);
gy_stencil = zeros(3, 3);

gx_stencil(:, 1) = -1;
gx_stencil(:, 3) = 1;

gy_stencil(1, :) = -1;
gy_stencil(3, :) = 1;

gx = imfilter(gray, gx_stencil); 
gy = imfilter(gray, gy_stencil); 

gxgy = gx .* gx + gy .* gy;
sum_grad = sum(gxgy(:));
mean0 = 6.29e5;
mean1 = 3.48e6;

d1 = abs(sum_grad - mean0);
d2 = abs(sum_grad - mean1);

p1 = d2 * d2 / (d2 * d2 + d1 * d1);

p = p1;
if p > 0.9
    p = 0.0; 
    return;
end

shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(62: round(h * 2 / 3), ...
round(w / 3):round(w * 2/ 3), :);

% --------------------------------------------------
% thresholding method-------------------------------
% otsu = graythresh(im_culled(:, :, 1));
otsu = 0.5922;
im_bin = im_culled(:, :, 1) > otsu * 255;
% im_bin = imbinarize((im_culled(:, :, 1)));
[gx, gy] = imgradientxy(im_bin);
idx = bitand(gy < 0, gx == 0);

[rows, cols] = find(idx);
y = median(rows);
y = round(y);
valid = size(rows) > 40;
if ~valid
    y = 255;
end


centers = [137, 168, 119] - 61;
dy = abs(y - centers);
p = 1.0 - dy(2) / (centers(2) - centers(1));
p = max(p, 0);
if y > centers(2)
    p = 1.0;
end

% --------------------------------------------------
% kmeans method-------------------------------
pts = double(reshape(im(:,:,1:3),288*352,3));
[cidx, ctrs] = kmeans(pts,3);
img = reshape(cidx,288,352);


group_dark = 1;
for i = 2:3
    if ctrs(i, 1) < ctrs(group_dark, 1)
        group_dark = i;
    end
end
group_coke = img == group_dark;
coke_culled = group_coke(70: round(h * 2 / 3), ...
round(w * 0.45):round(w * 0.55), :);
[rows, cols] = find(coke_culled);
y1 = min(rows);
if isempty(y1)
    y1 = 255;
end

centers = [137, 168, 119] - 69;
dy = abs(y1 - centers);
p1 = 1.0 - dy(2) / (centers(2) - centers(1));
p1 = max(p1, 0);
if y1 > centers(2)
    p1 = 1.0;
end

p = (p + p1) / 2;


end

% Defect 2: over-filled
function p = CS6640_defect_over_filled(im)
% CS6640_defect_over_filled - determine if over-filled
% On input:
%     im (MxNx3 array): input image
% On output:
%     p (float): probability over-filled
% Call:
%     b = CS6640_defect_over_filled(bot1);
% Author:
%     Haoyang Shi
%     UU
%     Fall 2025
%

shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(:, round(w / 3):round(w * 2/ 3), :);
gray = im2gray(im_culled);

gx_stencil = zeros(3, 3);
gy_stencil = zeros(3, 3);

gx_stencil(:, 1) = -1;
gx_stencil(:, 3) = 1;

gy_stencil(1, :) = -1;
gy_stencil(3, :) = 1;

gx = imfilter(gray, gx_stencil); 
gy = imfilter(gray, gy_stencil); 

gxgy = gx .* gx + gy .* gy;
sum_grad = sum(gxgy(:));
mean0 = 6.29e5;
mean1 = 3.48e6;

d1 = abs(sum_grad - mean0);
d2 = abs(sum_grad - mean1);

p1 = d2 * d2 / (d2 * d2 + d1 * d1);

p = p1;
if p > 0.9
    p = 0.0; 
    return;
end
shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(62: round(h * 2 / 3), ...
round(w / 3):round(w * 2/ 3), :);

% --------------------------------------------------
% thresholding method-------------------------------
otsu = 0.5922;
im_bin = im_culled(:, :, 1) > otsu * 255;

[gx, gy] = imgradientxy(im_bin);
idx = bitand(gy < 0, gx == 0);

[rows, cols] = find(idx);
y = median(rows);
y = round(y);
valid = size(rows) > 40;
if ~valid
    y = 255;
end


centers = [137, 168, 119] - 61;
dy = abs(y - centers);
p = 1- dy(3) / (centers(1) - centers(3));
p = max(p, 0);
if y < centers(3)
    p = 1;
end


%------------------------------
% kmeans method
pts = double(reshape(im(:,:,1:3),288*352,3));
[cidx, ctrs] = kmeans(pts,3);
img = reshape(cidx,288,352);


group_dark = 1;
for i = 2:3
    if ctrs(i, 1) < ctrs(group_dark, 1)
        group_dark = i;
    end
end
group_coke = img == group_dark;
coke_culled = group_coke(70: round(h * 2 / 3), ...
    round(w * 0.45):round(w * 0.55), :);
[rows, cols] = find(coke_culled);
y1 = min(rows);
if isempty(y1)
    y1 = 255;
end
centers = [137, 168, 119] - 69;
dy1 = abs(y1 - centers);
p1 = 1- dy1(3) / (centers(1) - centers(3));
p1 = max(p1, 0);
if y1 < centers(3)
    p1 = 1;
end

p = (p + p1) / 2;
end

% Defect 3: label missing
function p = CS6640_defect_label_missing(im)
% CS6640_defect_label_missing - determine if label missing
% On input:
%     im (MxNx3 array): input image
% On output:
%     p (float): probability label missing
% Call:
%     b = CS6640_defect_label_missing(bot1);
% Author:
%     <Your name>
%     UU
%     Fall 2025
%

p = 0;  % replace this with code to determine "Under-filled" probability
end

% Defect 4: white label
function p = CS6640_defect_white_label(im)
% CS6640_defect_white_label - determine if white label
% On input:
%     im (MxNx3 array): input image
% On output:
%     p (float): probability white lable
% Call:
%     b = CS6640_defect_white_label(bot1);
% Author:
%     Haoyang Shi
%     UU
%     Fall 2025
%

shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(:, round(w / 3):round(w * 2/ 3), :);
gray = im2gray(im_culled);

gx_stencil = zeros(3, 3);
gy_stencil = zeros(3, 3);

gx_stencil(:, 1) = -1;
gx_stencil(:, 3) = 1;

gy_stencil(1, :) = -1;
gy_stencil(3, :) = 1;

gx = imfilter(gray, gx_stencil); 
gy = imfilter(gray, gy_stencil); 

gxgy = gx .* gx + gy .* gy;
sum_grad = sum(gxgy(:));
mean0 = 6.29e5;
mean1 = 3.48e6;

d1 = abs(sum_grad - mean0);
d2 = abs(sum_grad - mean1);

p1 = d2 * d2 / (d2 * d2 + d1 * d1);

p = p1;
if p > 0.9
    p = 0.0; 
    return;
end

p = 0;  
[roi, r1, r2, c1, c2] = CS6640_get_center(im);
patch = roi(190: 270, :, :);

w = size(patch, 2);
h = size(patch, 1);
% % 1d fft
mags = zeros(w,1);
white = zeros(w, 1);
for col = 1: w
    line = patch(:, col, 3);
    x = fft(line);
    avg_mag = max(abs(x(2: h)));
    mags(col) = avg_mag;    
    white(col) = x(1);
end
% strength = mean(mags)
% whitescale = mean(white)


mag_mode_normal = 1.3e3;
white_mode = 1.4e4;
p_fft1 = size(find(mags < mag_mode_normal / 2 & ...
white > white_mode / 2), 1) / w;

% 2d fft
X = fft2(patch(:, :, 3));
mag = abs(X(2:h, 2: w));
mag_max = max(mag(:));
mag_mode_white = 1.5e4;
mag_mode_normal = 5e4;

dc_white_mode = 1.7e6;
dc_normal_mode = 7e5;
white = abs(X(1, 1));
p1 = max(0, 1 - (mag_max - mag_mode_white) / ...
(mag_mode_normal - mag_mode_white));
p2 = max(0, min(1, (white - dc_normal_mode) / ...
(dc_white_mode - dc_normal_mode)));

p_fft2 = p1 * p2;
p = (p_fft1 + p_fft2) / 2;
end

% Defect 5: not straight
function p = CS6640_defect_not_straight(im)
% CS6640_defect_under_filled - determine if undr-filled
% On input:
%     im (MxNx3 array): input image
% On output:
%     p (float): probability not straight
% Call:
%     b = CS6640_defect_not_straight(bot1);
% Author:
%     Haoyang Shi
%     UU
%     Fall 2025
%

% exclude no bottle case first
shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(:, round(w / 3):round(w * 2/ 3), :);
gray = im2gray(im_culled);

gx_stencil = zeros(3, 3);
gy_stencil = zeros(3, 3);

gx_stencil(:, 1) = -1;
gx_stencil(:, 3) = 1;

gy_stencil(1, :) = -1;
gy_stencil(3, :) = 1;

gx = imfilter(gray, gx_stencil); 
gy = imfilter(gray, gy_stencil); 

gxgy = gx .* gx + gy .* gy;
sum_grad = sum(gxgy(:));
mean0 = 6.29e5;
mean1 = 3.48e6;

d1 = abs(sum_grad - mean0);
d2 = abs(sum_grad - mean1);

p1 = d2 * d2 / (d2 * d2 + d1 * d1);

p = p1;
if p > 0.9
    p = 0.0; 
    return;
end

[roi, r1, r2, c1, c2] = CS6640_get_center(im);
patch = roi(170: 275, :, :);
patchg = im2gray(patch);
patchb = patchg > 150;
se = strel('line',10,0);
im6tc = imerode(patchb,se);
im6tc = imdilate(im6tc,se);

[l, n] = bwlabel(im6tc);

span_x = zeros(n);
for i = 1: n
    [rows, cols] = find(l == i);
    if isempty(rows)
        span_x(i) = 0;
    else
        span_x(i) = max(cols) - min(cols);
    end
end

[max_span, idx] = max(span_x(:));
if n > 0
    comp_strip = l == idx; 
else
    p = 0;
    return;
end
[rows, cols] = find(comp_strip);
s = size(rows, 1);
ri = round(s / 2);
r = rows(ri);
c = cols(ri);


% eigs method
scan1 = CS6640_range_scan(comp_strip,r, c);
reference = ones(5, 100);
scanref = CS6640_range_scan(reference, 3, 50);
% reference
pts2 = CS6640_scan2pts(scanref,35,28,10);
pts20 = [pts2(:,1)-mean(pts2(:,1)),pts2(:,2)-mean(pts2(:,2))];
CC2 = pts20'*pts20/length(pts20(:,1));
[VV2,DD2] = eigs(CC2);

% eigs for strip 
pts1 = CS6640_scan2pts(scan1,35,28,10);
pts10 = [pts1(:,1)-mean(pts1(:,1)),pts1(:,2)-mean(pts1(:,2))];
CC1 = pts10'*pts10/length(pts10(:,1));
[VV1,DD1] = eigs(CC1);

white = 0;
if DD1(2, 2) > DD1(1, 1) * 0.3
    white = 1;
end
if white
p1 = abs(VV1(2, 1));
else 
p1 = abs(VV1(2, 1)) / 0.1;
end
p1 = min(p1, 1.0);


% procrustes method
[rows, cols] = find(comp_strip);

% oracle to find corners
rpc = rows + cols; 
rmc = rows - cols;

[~, ibr] = max(rpc);
[~, itl] = min(rpc);
[~, ibl] = max(rmc);
[~, itr] = min(rmc);

br = [cols(ibr), rows(ibr)];
tl = [cols(itl), rows(itl)];
bl = [cols(ibl), rows(ibl)];
tr = [cols(itr), rows(itr)];

X = [tr; br; bl; tl; ];
Y = [100, 0; 100, 5; 0, 5; 0, 0; ];
[d,Z, transform] = procrustes(X,Y);

rotation = transform.T;
angle = rotation(2, 1);
p2 = abs(angle) / 0.1;
p2 = min(p2, 1.0);

p = (p1 + p2) / 2;
end

% Defect 6: no cap
function p = CS6640_defect_no_cap(im)
% CS6640_defect_no_cap - determine if no cap
% On input:
%     im (MxNx3 array): input image
% On output:
%     p (float): probability no cap
% Call:
%     b = CS6640_defect_no_cap(bot1);
% Author:
%     Haoyang Shi
%     UU
%     Fall 2025
%

% texture method

shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(:, round(w / 3):round(w * 2/ 3), :);
gray = im2gray(im_culled);

gx_stencil = zeros(3, 3);
gy_stencil = zeros(3, 3);

gx_stencil(:, 1) = -1;
gx_stencil(:, 3) = 1;

gy_stencil(1, :) = -1;
gy_stencil(3, :) = 1;

gx = imfilter(gray, gx_stencil); 
gy = imfilter(gray, gy_stencil); 

gxgy = gx .* gx + gy .* gy;
sum_grad = sum(gxgy(:));
mean0 = 6.29e5;
mean1 = 3.48e6;

d1 = abs(sum_grad - mean0);
d2 = abs(sum_grad - mean1);

p1 = d2 * d2 / (d2 * d2 + d1 * d1);

p = p1;
if p > 0.9
    p = 0.0; 
    return;
end
shape = size(im);
w = shape(2);
h = shape(1); 
cx = find_center(im); 
im_culled = im(1: 150, cx - 65: cx + 65, :);

texture = stdfilt(im_culled, true(5));
window = im_culled(20: 40, 55: 75, :);
texture_window = texture(20: 40, 55: 75, 1);
mean_texture = mean(texture_window, [1, 2]);

variance_texture = std(texture_window, 0, [1, 2]);
mean_texture(:);

% find the ratio of pixels with texture value > 5.0
large_var = texture_window(:) > 6.0;
percent = sum(large_var);
percent = percent / (21 * 21);

p0 = percent;

% edge method
thres = 0.15;
gray = im2gray(im_culled);
[bw1, thres] = edge(gray, 'Prewitt', thres);
scanline = 0;
for i = 55: 75
    for j = 1: 10
        if bw1(j, i)
            scanline = scanline + 1;
            break;
        end
    end 
end
p1 = 1 - scanline / 21;
p = (p0 + p1) / 2;
end

% Defect 7: deformed
function p = CS6640_defect_deformed(im)
% CS6640_defect_deformed - determine if deformed
% On input:
%     im (MxNx3 array): input image
% On output:
%     p (float): probability deformed
% Call:
%     b = CS6640_defect_deformed(bot1);
% Author:
%     <Your name>
%     UU
%     Fall 2025
%

p = 0;  % replace this with code to determine "Deformed" probability
end

% Defect 8: No bottle
function p = CS6640_defect_no_bottle(im)
% CS6640_defect_no_bottle - determine if no bottle in middle of image
% On input:
%     im (MxNx3 array): input image
% On output:
%     p (float): probability there's no bottle in middle
% Call:
%     b = CS6640_defect_no_bottle(bot1);
% Author:
%     Haoyang Shi
%     UU
%     Fall 2025
%
% convolution method

shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(:, round(w / 3):round(w * 2/ 3), :);
gray = im2gray(im_culled);

gx_stencil = zeros(3, 3);
gy_stencil = zeros(3, 3);

gx_stencil(:, 1) = -1;
gx_stencil(:, 3) = 1;

gy_stencil(1, :) = -1;
gy_stencil(3, :) = 1;

gx = imfilter(gray, gx_stencil); 
gy = imfilter(gray, gy_stencil); 

gxgy = gx .* gx + gy .* gy;
sum_grad = sum(gxgy(:));
mean0 = 6.29e5;
mean1 = 3.48e6;

d1 = abs(sum_grad - mean0);
d2 = abs(sum_grad - mean1);

p1 = d2 * d2 / (d2 * d2 + d1 * d1);

p = p1;
end

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
end

function pts = CS6640_scan2pts(scan,r,c,num_rows)
% CS6640_scan2pts - convert 360 degree range scan to x,y point set
% On input:
%     scan (1x360 vector): distance to background in 1 degree directions
%     r (int): row value
%     c (int): column value
%     num_rows (int): number of rows in scanned image
% On output:
%     pts (nx2 array): x,y coordinates of the 360 scan distances
% Call:
%     pts1 = CS6640_scan2pts(scan1,185,181,288);
% Author:
%     T. Henderson
%     UU
%     Fall 2025
%

DEG2RAD = pi/180;

x = c;
y = num_rows - r + 1;

ppts = zeros(360,2);
for p = 1:360
    rho = scan(p);
    theta = (p-1)*DEG2RAD;
    del_y = sin(theta);
    del_x = cos(theta);
    pts(p,1) = x + rho*del_x;
    pts(p,2) = y + rho*del_y;
end
end
function scan = CS6640_range_scan(im,r,c)
% CS6640_range_scan - 360 degree scan of pixel neighborhood
% On input:
%     im (MxN array): binary image
%     r (int): row value
%     c (int): column value
% On output:
%     scan (1x360 vector): distance to background in 1 degree directions
% Call:
%     scan1 = CS6640_range_scan(im1t,185,181);
% Author:
%     T. Henderson
%     UU
%     Fall 2025
%

DEL_THETA = 1;
step = 0.1;

scan = zeros(1,360);
for a = 0:359
    theta = a*pi/180;
    scan(a+1) = CS6640_dist_to_bkgnd_3(im,r,c,theta,step);
end
end
function d = CS6640_dist_to_bkgnd_3(im,r,c,theta,step)
% CS6640_dist_to_bkgnd_3 - find distance in dir theta to background
% On input:
%     im (MxN array): binary image
%     r (int): row value
%     c (int): column value
%     theta (float radians): direction to look
%     step (float): step size to move in scan direction
% On output:
%     d (float): distance to background in direction theta
% Call:
%     scan(a+1) = CS6640_dist_to_bkgnd_3(im,r,c,pi/4,0.2);
% Author:
%     T. Henderson
%     UU
%     Fall 2025
%

[num_rows,num_cols] = size(im);
done = 0;
r_cur = r;
c_cur = c;
del_row = -step*sin(theta);
del_col = step*cos(theta);
while done==0
    r_cur = r_cur + del_row;
    c_cur = c_cur + del_col;
    r_int = round(r_cur);
    c_int = round(c_cur);
    if (r_int<1)||(r_int>=num_rows)||(c_int<1)||(c_int>=num_cols)
        done = 1;
    else
        r_min = max(1,r_int-1);
        r_max = min(num_rows,r_int+1);
        c_min = max(1,c_int-1);
        c_max = min(num_cols,c_int+1);
        if sum(sum(im(r_min:r_max,c_min:c_max)))==0
            done = 1;
        end
    end
end

d = norm([r;c]-[r_cur;c_cur]);
end

function cx = find_center(im)

% scanline 25
scanline = im(25, :, :);
is_red = scanline(:, :, 1) > 150 & ...
    scanline(:, :, 2) < 100 & ...
    scanline(:, :, 3) < 100;

rises = find(diff(is_red) == 1);
falls = find(diff(is_red) == -1);
n_caps = max(length(rises), length(falls));

cap_size = 55;
bottle_size = 130;
if n_caps == 3
    if length(rises) == 3 && length(falls) == 3
        cx = round((rises(2) + falls(2)) / 2);
    elseif length(rises) == 2 && length(falls) == 3
        cx = round((rises(1) + falls(2)) / 2);
    elseif length(rises) == 3 && length(falls) == 2
        cx = round((rises(2) + falls(2)) / 2);
    end
elseif n_caps == 2
    if length(rises) == 2
        gap = rises(2) - rises(1);
        center_missing = gap > bottle_size * 1.5;
        if (center_missing)
            cx = round((rises(1) + rises(2) + cap_size) / 2);
        else
            c1 = round(rises(1) + cap_size / 2);
            c2 = round(rises(2) + cap_size / 2);
            if abs(c1 - 176) < abs(c2 - 176)
                cx = c1;
            else
                cx = c2;
            end
        end 
    elseif length(falls) == 2
        gap = falls(2) - falls(1);
        center_missing = gap > bottle_size * 1.5;
        if (center_missing)
            cx = round((falls(1) + falls(2) + cap_size) / 2);
        else
            c1 = round(falls(1) - cap_size / 2);
            c2 = round(falls(2) - cap_size / 2);
            if abs(c1 - 176) < abs(c2 - 176)
                cx = c1;
            else
                cx = c2;
            end
        end
    end
    
else 
    cx = 176;
end

if cx < 66
    cx = 66;
elseif cx + 65 > 352
    cx = 352 - 65;
end
end