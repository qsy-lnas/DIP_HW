
b  =1;
if b == 1

    [image, ~, alpha] = imread("lounge-hdr-foreground.png");
    image_ = imread("lounge-hdr-background.png");
end
image_scale = image > 0;
j = image(:, :, 1);
i = ~image(:, :, 1);
a = size(image(:, :, 1));
image_scale(200, :)
imshow(uint8(image_scale) .* image_);
