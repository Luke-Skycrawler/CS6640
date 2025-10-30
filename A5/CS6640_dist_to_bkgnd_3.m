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
