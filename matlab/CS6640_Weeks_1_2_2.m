function CS6640_Weeks_1_2_2
%

% Week 2
% Solving least squares fit for b = Ax
% discuss arithmetic operators on uint8 (not)

load('trees.mat');
trees = ind2rgb(X,map);
treesg = rgb2gray(trees);

A = zeros(5,3);
A(1,:) = [231,247,255];   % Pixel (30,49)
A(2,:) = [16,16,8];   % Pixel (59,26)
A(3,:) = [173,41,24];   % Pixel (100,17)
A(4,:) = [66,107,24];   % Pixel (118,138)
A(5,:) = [82,148,198];   % Pixel (146,244)

b = zeros(5,1);
b(1) = 243;      % treesg(30,49)
b(2) = 15;       % treesg(59,26)
b(3) = 79;       % treesg(100,17)
b(4) = 85;       % treesg(118,138)
b(5) = 134;      % treesg(146,244)

x = A\b    % found with 5 linear equations

% Try full image
b = treesg(:);
A = reshape(trees,258*350,3);
coeffs = A\b
book_coeff = [0.2989; 0.587; 0.114]

% Chapter 2

% Make a circle image
circle = zeros(51,51);
for r = 1:51
    for c = 1:51
        if abs(norm([r;c]-[25;25])-10)<2
            circle(r,c) = 1;
        end
    end
end
figure(1)
clf
subplot(2,4,1);
imshow(~circle)
title('X');

% Make plus image
plus = zeros(51,51);
plus(24:26,17:33) = 1;
plus(17:33,24:26) = 1;
subplot(2,4,2);
imshow(~plus);
title('Y');

W = ones(3,3)/9;
circleb = conv2(circle,W,'same');
subplot(2,4,5);
imshow(~circleb);
title('S(X)');
plusb = conv2(plus,W,'same');
subplot(2,4,6);
imshow(~plusb);
title('S(Y)');
both = circle + plus;
subplot(2,4,3);
imshow(~both);
title('X+Y');
bothb = circleb + plusb;
subplot(2,4,4);
imshow(~bothb);
title('S(X) + S(Y)');
subplot(2,4,8);
CpPb = conv2(circle+plus,W,'same');
imshow(~(CpPb));
title('S(X+Y)');
tch = 0;

% Linear superposition

bothb(21,14)     % S(X) + S(Y) at 21,14
CpPb(21,14)      % S(X+Y)      at 21,14

% Convolution with an image
C = [4,3,2; 5,0,1; 6,7,8]  % dir = 45*(v-1)
Cr = imrotate(C,180)
% equation is: h(x,y; x'y') = h(x-x',y-y')
%  consider at x=y=0    h(0,0,; x',y') = h(-x',-y');
%  h indexes in x',y'
%                     ^
%                     | y
%         +-------+-------+------+
%         | -1,1  |  0,1  |  1,1 |
%         +-------+-------+------+
%         | -1,0  |  0,0  |  1,0 |------->
%         +-------+-------+------+      x
%         | -1,-1 |  0,-1 | 1,-1 |
%         +-------+-------+------+
%
%  180 deg rotated h indexes in x',y'
%                     ^
%                     | y
%         +-------+-------+------+
%         |  1,-1 |  0,-1 |-1,-1 |
%         +-------+-------+------+
%         |  1,0  |  0,0  | -1,0 |------->
%         +-------+-------+------+      x
%         |  1,1  |  0,1  | -1,1 |
%         +-------+-------+------+
%
%   sum is:
%  f(0,0)h(0,0) + f(1,0)h(-1,0) + f(1,1)h(-1,-1) + f(0,1)h(0,-1) + ...
%  f(-1,1)h(1,-1) + f(-1,0)h(1,0) + f(-1,-1)h(1,1) + f(0,-1)h(0,1) + ...
%  f(1,1)h(-1,-1)

% why consider this a rotation?
theta = pi
T = [cos(theta) -sin(theta); sin(theta) cos(theta)]
% but -x is a reflection about y axis
%     -y is a reflection about x axis
% x --> -x
% y --> -y
%
v1 = [1;1]
T*v1
v2 = [-1;1]
T*v2
v3 = [-1;-1]
T*v3
v4 = [1;-1]
T*v4
% because rotation by 180 is same as reflection about x & y axes

c1 = imfilter(circle,C,'conv','same');
c2 = imfilter(circle,Cr,'corr','same');
figure(1);
clf
subplot(1,3,1);
surf(c1);
title('Convolution with C');
axis equal
subplot(1,3,2);
surf(c2);
title('Correlation with Cr');
axis equal
subplot(1,3,3);
surf(abs(c1-c2));
title('Difference');
axis equal

f = [1 2 3 4 5]
h = [5 4 3 2 1]
g = conv(f,h)

f = [ 1 2; 3 4]
h = [5 6; 7 8]
g = conv2(f,h)

% Use discrete unit impulse to discover filter
f = [0 0 0 1 0 0 0 0]'
h = [1 2 4 2 8]'
g = conv(f,h)

f = zeros(5,5);
f(3,3) = 1
h = [5,6; 7,8]
g = conv2(f,h)

% Impulse Response
W = 2*rand(3,3)
D = zeros(5,5);
D(3,3) = 1
h = conv2(D,W,'same')

tch = 0;

% Camera Model
N = 10;
X = ones(N,3);
X(1:2:N,1) = -1;
for k = 1:N/2
    ind1 = (k-1)*2 + 1;
    X(ind1:ind1+1,2) = k - 1;
    X(ind1:ind1+1,3) = k;
end
figure(1);
clf
subplot(2,1,1);
plot3(X(:,1),X(:,2),X(:,3),'ko');
hold on
plot3(min(X(:,1))-0.1,min(X(:,2))-0.1,min(X(:,3))-0.1,'w.');
plot3(max(X(:,1))+0.1,max(X(:,2))+0.1,max(X(:,3))+0.1,'w.');

f = 1;
x = f*X(:,1)./X(:,3);
y = f*X(:,2)./X(:,3);
[x,y]

subplot(2,1,2);
plot(x,y,'ro');
hold on
plot(min(x)-0.1,min(y)-0.1,'w.');
plot(max(x)+0.1,max(y)+0.1,'w.');
plot(x(1:2:N-1),y(1:2:N-1),'g');
plot(x(2:2:N),y(2:2:N),'b');

% Gaussian
figure(2);
clf
samps = randn(10000,1);
hist(samps);
hist(samps,2);
samps2D = randn(10000,2);
hist3(samps2D,'Nbins',[15,15]);

z = [-5:0.1:5];
v = normpdf(z);
plot(v);

% Project ideas
% color
im1 = imread('bottle_images\image001.jpg');
[M,N,P] = size(im1)
X = reshape(double(im1),M*N,P);
[cidx,ctrs] = kmeans(X,6);
cidx_im = reshape(cidx,M,N);
for k = 1:6
    combo(im1,~(cidx_im==k));
    input('Go? ');
end
[X,map] = rgb2ind(im1,6);
for k = 1:6
    combo(im1,~(X==k));
    input('Go? ');
end

% Pixels: (20,175), (25,189), (29,123)
ctrs = [241,65,18; 52,38,3; 252,237,194];
imo = CS6640_ctr_dist(im1,ctrs);
imshow(imo==1);
imshow(imo==2);
imshow(imo==3);

% Gray level
im1g = rgb2gray(im1);
[cidx,ctrs] = kmeans(im1g(:),5);
cidx_im = reshape(cidx,M,N);
for k = 1:5
    combo(im1,~(~(cidx_im==k)));
    input('Go? ');
end

% Slices
sl = CS4640_slices(im1g);

tch = 0;

