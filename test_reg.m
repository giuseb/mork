clear

i = imread('./spec/samples/angolo.jpg');
ig = 255 - rgb2gray(i);

% the horizontal signal
hs = sum(ig, 1);
% the vertical signal
vs = sum(ig, 2);

% kernel half size, to be determined
khs = 15;
% kernel X axis
x = -khs:khs;
% kernel full size
ksize = length(x);
% KERNEL
y=sqrt(khs^2 - x.^2);

% image YX sizes
[vp, hp] = size(ig);

xmin = nan(1, hp);
ymin = nan(1, vp);

for i = 1:hp-ksize;
   tx = hs(i:i+ksize-1); % the X values for the current step
   y=sqrt(khs^2 - x.^2)/khs*max(tx);
   xmin(i+khs) = sum((hs(i:i+ksize-1)-y ) .^ 2);
   %    ymin(i+khs) = sum((vs(i:i+ksize-1)-y') .^ 2);
end

% plot(1:hp, [hs; xmin])
plot(1:hp, xmin)

cx = find(xmin==nanmin(xmin));
cy = find(ymin==nanmin(ymin));
fprintf('X: %d; Y: %d\n', cx, cy);

