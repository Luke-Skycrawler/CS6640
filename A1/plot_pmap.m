function [] = plot_pmap(c, k)
    x = linspace(0, 1, 100);
    y = pmap(x, c, k);
    plot(x, y);
end