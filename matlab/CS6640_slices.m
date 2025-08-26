function slices = CS6640_slices(im)
% CS6640_slices - computes the bit slices of a uint8 image
% On input:
%     im (MxNx3 RGB image): input image
% On output:
%     slices (MxNx8 uint8 image): bit slices in each channel
% Call:
%     CS6640_slices(trees_rgb);
% Author:
%     T. Henderson
%     UU
%     Summer 2019
%

[M,N,P] = size(im);
slices = zeros(M,N,8);
clf

subplot(3,3,1);
imshow(im);
title('Original Image');
img = uint8(255*rgb2gray(im));

for s = 8:-1:1
    for r = 1:M
        for c = 1:N
            b = bitget(img(r,c),s);
            if b>0
                slices(r,c,s) = bitset(slices(r,c,s),s);
            end
        end
    end
    subplot(3,3,s+1);
    imagesc(slices(:,:,s));
    title(['Level Slice: ',num2str(s)]);
end
end