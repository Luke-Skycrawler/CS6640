
function p = pmap(x, c, w)
    k = 2*log(9)/w;
    p = 1 ./ (1 + exp(-k*(x - c)));
    % p = atan(k * (r - c)) / pi + 0.5;
end