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
for k = 97:97
    report(k).name = [];
    report(k).defects = [];
end
defects = zeros(number_of_files,8);

for k = 1:number_of_files
    filename = list(k).name;
    report(k).name = [d_name,'\',filename]; %filename;
    I = imread([d_name,'\',filename]);
    d = zeros(1,8);

    % check for no bottle error
    d(8) = CS6640_defect_no_bottle(I);
    defects(k,:) = d;
    if d(8) > thresholds(8)
        report(k).defects = defect_names(8);
    end
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
%     <Your name>
%     UU
%     Fall 2025
%

p = 0;  % replace this with code to determine "Under-filled" probability
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
%     <Your name>
%     UU
%     Fall 2025
%

p = 0;  % replace this with code to determine "over-filled" probability
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

p = 0;  % replace this line with code to determine "No bottle" probability
shape = size(im);
w = shape(2);
h = shape(1);
im_culled = im(:, round(w / 3):round(w * 2/ 3), :);
%imshow(im_culled);
gray = im2gray(im_culled);
%gray = im_culled(:, :, 2);
%max(gray(:));
%figure;
% imhist(gray);
%otsu = graythresh(gray);
otsu = 150 / 255;
l = gray < otsu * 255;
u = gray >= otsu * 255;

nnz = sum(u(:));
ratio = nnz / (nnz + sum(l(:)));
p = pmap(ratio, 0.85, 0.05);
%p = ratio;
%[counts, bins] = imhist(gray);
end



