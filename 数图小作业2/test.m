
b  =1;
if b == 1

    image = imread("lounge-hdr-foreground.png");
    [~, ~, alpha] = imread("lounge-hdr-foreground.png");
    image_ = imread("lounge-hdr-background.png");
end
image_scale = image > 0;
image_scale_ = image == 255;
i = image(:, :, 1);
j = image_scale(:, :, 1);
k = image_scale_(:, :, 1);
s = alpha;
image_processed = background.*uint8(~forescope) + foreground;
a = size(image(:, :, 1));
image_scale(200, :)
imshow(uint8(image_scale) .* image_);
