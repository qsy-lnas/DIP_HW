
b  =1;
if b == 1

    image = imread("lounge-hdr-foreground.png");
    [image__, ~, alpha] = imread("lounge-hdr-foreground.png");
    image_ = imread("lounge-hdr-background.png");
end

imshow(image__);
