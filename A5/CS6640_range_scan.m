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
