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
    if d(8) > thresholds(8)
        report(k).defects = defect_names(8);
    else  
        d(1) = CS6640_defect_under_filled(I);
        d(2) = CS6640_defect_over_filled(I);

        for j = 1: 2
            if d(j) > thresholds(j)
                report(k).defects = defect_names(j);
            end
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
im_culled = im(62: round(h * 2 / 3), round(w / 3):round(w * 2/ 3), :);

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
p = 1- dy(2) / (centers(2) - centers(1));
p = max(p, 0);
if y > centers(2)
    p = 1;
end
% idx(:, 2)
% imagesc(gy);
% imagesc(im_bin);
% imagesc(idx);


% --------------------------------------------------
% kmeans method-------------------------------

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
im_culled = im(62: round(h * 2 / 3), round(w / 3):round(w * 2/ 3), :);

% --------------------------------------------------
% thresholding method-------------------------------
im_bin = imbinarize((im_culled(:, :, 1)));
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
%     <Your name>
%     UU
%     Fall 2025
%

p = 0;  % replace this with code to determine "White label" probability
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
%     <Your name>
%     UU
%     Fall 2025
%

p = 0;  % replace this with code to determine "No cap" probability
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
