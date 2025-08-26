function CS6640_show_density(imd,lb,ub)
% CS6640_show_density - show 3D density
% On input:
%     imd (MxNxP array): denity array
%     lb (float): lower bound on density to show
%     ub (float): upper bound on density to show
% On output:
%    3D plot of densities
% Call:
%     CS6640_show_density(imd,0.01,0.3);
% Author:
%     T. Henderson
%     UU
%     Fall 2021
%

[M,N,P] = size(imd);
clf
hold on
axis equal
plot3(-1,-1,-1,'w.');
plot3(M+1,N+1,P+1,'w.');
for r = 1:M
    for c = 1:N
        for d = 1:P
            if imd(r,c,d)>lb&imd(r,c,d)<ub
                plot3(r,c,d,'k*');
            end
        end
    end
end
