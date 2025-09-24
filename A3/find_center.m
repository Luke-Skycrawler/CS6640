
function cx = find_center(im)

% d_name = 'All';
% filename = 'image109.jpg';
% im = imread([d_name,'\',filename]);
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
% figure();
% plot(is_red); 

end