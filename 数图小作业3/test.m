an = 0;
ph = 0;
fr = 0.002;
[X, Y] = meshgrid(1 : 256);
im = cos(2 .* pi .* fr .* (cos(an) * X + sin(an) * Y) + ph);
imshow(im);
pi
