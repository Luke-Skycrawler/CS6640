function [m0, m1] = means(grads)
    defects = [18	25	45	47	69	89	105	116	119	120	122	133];
    mask_t = true(141, 1);
    mask_t(defects) = false;
    
    m0 = mean(grads(defects));
    m1 = mean(grads(mask_t));
end