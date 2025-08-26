function CS6640_Weeks_1_2
% CS6640 Weeks 1-2 Demo Matlab function

% Demo CS6640_show_images
figure(1);
clf
% CS6640_show_images('bottle_images');

rng('default');  % Initialize random seed

im = rand(11,11)<0.5;
im
im(2,4)

clf
subplot(3,1,1);
imshow(~im);
subplot(3,1,2);
[rows,cols] = find(im);
plot(rows,cols,'k*');
axis equal
subplot(3,1,3);
plot(cols,11-rows+1,'k*');
axis equal

class(im)
img = mat2gray(im);
class(img)
img = uint8(img);
class(img)

im1 = imread('bottle_images\image001.jpg');
class(im1)

% 3D images (density)
imd = CS6640_make_density(21,21,21);
CS6640_show_density(imd,0.01,0.3);
CS6640_show_density(imd,0.001,0.01);
CS6640_show_density(imd,0.0001,0.001);

% indexed images
clf
who
load('trees.mat');
who
size(X)
size(map);
imshow(X,map);
impixelinfo
plot(map(:,1),'r');
hold on
plot(map(:,2),'g');
plot(map(:,3),'b');
plot(64,map(64,1),'ko');
plot(64,map(64,2),'ko');
plot(64,map(64,3),'ko');
map(64,:)

trees_rgb = ind2rgb(X,map);
imshow(trees_rgb);
[trees_ind,map_ind] = rgb2ind(trees_rgb,128);
imshow(trees_ind,map_ind);
map2 = rand(128,3);
imshow(X,map2);
map2 = rand(128,3);
imshow(X,map2);

size(trees_rgb)
ims = trees_rgb(88:99,82:91,:)
imshow(ims)
impixelinfo
imshow(trees_rgb(:,:,1));

trees_hsv = rgb2hsv(trees_rgb);
imshow(trees_hsv);
imshow(trees_hsv(:,:,1));
imshow(trees_hsv(:,:,2));
imshow(trees_hsv(:,:,3));
figure(2)
imshow(rgb2gray(trees_rgb));

% slices
ims = CS6640_slices(trees_rgb);

% RGB to gray level coefficients
im1 = trees_rgb(101:150,101:150,:);
imr = im1(:,:,1);
img = im1(:,:,2);
imb = im1(:,:,3);
A = zeros(2500,3);
A(:,3) = imb(:);
A(:,2) = img(:);
A(:,1) = imr(:);
c = rand(3,1);
c = c/norm(c);
im2 = A*c;
im2i = reshape(im2,50,50);
figure(1);
imshow(im1);
figure(2);
clf
imshow(im2i);

% Finding the rgb2gray coefficients
im = ind2rgb(X,map);
img = rgb2gray(im);
b = img(:);
[M,N] = size(img)
size(b)
M*N
A = reshape(im,M*N,3);
coeffs = A\b

% 1D convolution
f = [1,2,3,4,5];
h = [5,4,3,2,1];
g = conv(f,h)

% 2D convolution
f = [1 2; 3 4]
h = [5 6; 7 8]
conv2(f,h)

tch = 0;
