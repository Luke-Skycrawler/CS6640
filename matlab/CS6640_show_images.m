function CS6640_show_images(d_name)
% CS6640_show_images - show all images in a directory
% On input:
%     d_name (string): name of directory path
% On output:
%     N/A (displays images)
% Call:
%     CS6640_show_images('bottle_images');
% Author:
%    Modified by Tom Henderson from:
% Example Matlab script as provided with textbook:
%
%  Fundamentals of Digital Image Processing: A Practical Approach with Examples in Matlab
%  Chris J. Solomon and Toby P. Breckon, Wiley-Blackwell, 2010
%  ISBN: 0470844736, DOI:10.1002/9780470689776, http://www.fundipbook.com
%

%% cycle through all PNG files in a given directory
%% (and in this case display them)
%% [for use with suggested student projects on www.fundipbook.com/materials/]

%% change '*.png' in code below for other image types
%% (TCH): changed to '*.jpg'

h_name = pwd;
cd(d_name);

list = dir('*.jpg');
number_of_files = size(list);

for k = 1: number_of_files(1,1)
    filename = list(k).name;
    I = imread(filename);
    cmd = input('Next: (RETURN for next; 0 to quit)');
    if cmd==0
        cd(h_name);
        return
    else
        imshow(I);
        title(filename);
    end
end
cd(h_name);
