function im = CS6640_make_density(M,N,P)
% CS6640_make_density - make 3D density array
% On input:
%     M (int): row size
%     N (int): column size
%     P (int): plane size
% On output:
%    im( MxNxP array): MxNxP array of densities
% Call:
%     CS6640_make_density(21,21,21);
% Author:
%     T. Henderson
%     UU
%     Fall 2021
%

im = zeros(M,N,P);
mid_pt = [(M+1)/2;(N+1)/2;(P+1)/2];
max_val = norm([M,N,P]);

for r = 1:M
    for c = 1:N
        for p = 1:P
            im(r,c,p) = exp(-norm([r;c;p]-mid_pt));
        end
    end
end
