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
