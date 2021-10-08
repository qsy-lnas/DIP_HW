
b  =1;
if b == 1

    image = imread("op1_bg.png");
    [image__, ~, alpha] = imread("op1_fg.png");
    image_ = imread("lounge-hdr-background.png");
end

imshow(image__);
