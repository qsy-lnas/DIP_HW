%% 数字图像处理第四次作业
clear; 
clc;
close all;
image_dir = 'LUT_ini.jpg'; % 
image_poppy = "LUT_poppy55.jpg";
image_autumn = "LUT_autumn100.jpg";
image_sepia = "LUT_sepia40.jpg";
image_human = "puking.jpg";
image_other = "build.jpg";
human_poppy = "puking_poppy.jpg";
human_autumn = "puking_autumn.jpg";
human_sepia = "puking_sepia.jpg";
other_poppy = "build_poppy.jpg";
other_autumn = "build_autumn.jpg";
other_sepia = "build_sepia.jpg";
save_human_poppy = "puking_poppy_proc.jpg";
save_human_autumn = "puking_autumn_proc.jpg";
save_human_sepia = "puking_sepia_proc.jpg";
save_other_poppy = "build_poppy_proc.jpg";
save_other_autumn = "build_autumn_proc.jpg";
save_other_sepia = "build_sepia_proc.jpg";
% other global variable
type = 3; 
% type = 1,     2,      3
% name = poppy, autumn, sepia
%% generate LUT3D ini
lut_ini = zeros(512, 512, 3);
for i = 1:8
    for j = 1:8
        for m = 1:64
            for n = 1:64
                lut_ini((i - 1) * 64 + m, (j - 1) * 64 + n, 1) ...
                    = 4 * (n - 1) + 3;
            end
            lut_ini((i - 1) * 64 + m, (j * 64 - 63: j * 64), 2)...
                = 4 * (m - 1) + 3;
        end
        lut_ini((i * 64 - 63: i * 64), (j * 64 - 63: j* 64), 3) ...
            = 32*(i - 1) + 4 * (j - 2);
    end
end
lut_ini = uint8(lut_ini);
%figure(1), imshow(lut_ini);
imwrite(lut_ini, image_dir, "jpg");

%% load image depend on type

human = imread(image_human);
other = imread(image_other);
switch type
    case 1 % poppy
        lut = imread(image_poppy);
        human_ex = imread(human_poppy);
        other_ex = imread(other_poppy);
        human_dir = save_human_poppy;
        other_dir = save_other_poppy;
    case 2 % autumn
        lut = imread(image_autumn);
        human_ex = imread(human_autumn);
        other_ex = imread(other_autumn);
        human_dir = save_other_autumn;
        other_dir = save_other_autumn;
    case 3 % sepia
        lut =  imread(image_sepia);
        human_ex = imread(human_sepia);
        other_ex = imread(other_sepia);
        human_dir = save_human_sepia;
        other_dir = save_other_sepia;
end

%% process, save and show image
lut_3d = trlut(lut);
human_proc = imlut(human, lut_3d);
other_proc = imlut(other, lut_3d);
imwrite(human_proc, human_dir, "jpg");
imwrite(other_proc, other_dir, "jpg");

subplot(2, 3, 1); imshow(human);
subplot(2, 3, 2); imshow(human_ex);
subplot(2, 3, 3); imshow(human_proc);
subplot(2, 3, 4); imshow(other);
subplot(2, 3, 5); imshow(other_ex);
subplot(2, 3, 6); imshow(other_proc);

%% 将LUT图转换为对应的RGB图片 512*512 -> 256*256*256
function lut3D = trlut(lut)
lut3D = uint8(zeros(256, 256, 256, 3));
a = uint8(zeros(64, 64, 64, 3));
for i = 1:64
    for j = 1:64
        for k = 1:64
            a(j, k, i,:) = lut(floor((i-1)/8)*64+k, mod(i-1, 8)*64+j, :);
        end
    end
end
lut3D(:, :, :, 1) = imresize3(a(:, :, :, 1), [256 256 256]);
lut3D(:, :, :, 2) = imresize3(a(:, :, :, 2), [256 256 256]);
lut3D(:, :, :, 3) = imresize3(a(:, :, :, 3), [256 256 256]);
end

%% 对输入图像Img做LUT变换，lut为256*256*256*3
function img_proc = imlut(img, lut)
[a, b, c] = size(img);
img_proc = uint8(zeros(a, b, c));
for i = 1:a
    for j = 1:b
        R = img(i, j, 1);
        G = img(i, j, 2);
        B = img(i, j, 3);
        img_proc(i, j, :) = lut(R+1, G+1, B+1, :);
    end
end
end
