an = 0;
ph = 0;
fr = 0.002;
sigma = 10;
[X, Y] = meshgrid(1 : 256);
sum = im(128, 128) + im(128, 129) + ...
    im(129, 128) + im(129, 129);
sum = sum ./ 4;
a = 1 ./ sum;
im = (X - 128.5) .^ 2 + (Y - 128.5) .^ 2;
im = - im ./ (2 .* sigma .^ 2);
im = exp(im) ./ (2 .* pi .* sigma .^ 2);
im = im .* a .* 10;
imshow(im);

