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
%     <Your name>
%     UU
%     Fall 2025
%

p = 0;  % replace this with code to determine "Not straight" probability
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

