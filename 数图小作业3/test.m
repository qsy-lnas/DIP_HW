im = zeros(256, 256);
im(96: 160, 64: 192) = 0.5;
step = 4;
[Y, X] = meshgrid(1: step: 256, 1: step: 256);
surf(X, Y, im(1 : step: 256, 1: step: 256))
% colorbar
% [X,Y] = meshgrid(1:10,1:20);
% Z = sin(X) + cos(Y);
% surf(X,Y,Z)