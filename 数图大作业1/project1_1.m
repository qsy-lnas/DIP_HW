%% 数字图像处理第一次大作业
clear; 
clc;
close all;

%% select image
image_id = 1;

%% Global variables
% 源图片路径
image1_dir = '1.bmp'; 
image2_dir = '2.bmp';
image3_dir = '3.bmp';
file_type = '.bmp'; % 图片文件类型为bmp
% other global variable
sblock = 16;
lblock = 30;

%% Initial proccess
switch image_id
    case 1
        I = imread(image1_dir);
        I = padarray(I, [3, 3], 255);
    case 2
        I = imread(image2_dir);
    case 3
        I = imread(image3_dir);
end
[M, N] = size(I);
M_pixel = floor(M / sblock);
N_pixel = floor(N / sblock);
% 3*3均值滤波
I = imfilter(I, fspecial('average', [3, 3]));
I = I(2:M - 1, 2:N - 1);
% 初始化频率图，方向图，方差图等
Frequency = zeros(M_pixel, N_pixel);
Direction = zeros(M_pixel, N_pixel);
Variance = zeros(M_pixel, N_pixel);
Flag = zeros(M_pixel, N_pixel);
% 填充图像
I = im2double(I);
%I_padding = padarray(I, [(lblock - sblock) / 2,...
%    (lblock - sblock) / 2], 255);
[X, Y] = size(I);

%% 图像分块与求取方向频率图
for i = 0 : ceil(X / sblock) - 1
    for j = 0 : ceil(Y / sblock) - 1
        % 计算以小块为中心的大块的边际点坐标+特判
        x0 = ((i * sblock - (lblock - sblock) / 2) < 1) + ((i * sblock - (lblock - sblock) / 2) >= 1) * (i * sblock - (lblock - sblock) / 2); 
        y0 = ((j * sblock - (lblock - sblock) / 2) < 1) + ((j * sblock - (lblock - sblock) / 2) >= 1) * (j * sblock - (lblock - sblock) / 2); 
        x1 = ((i * sblock + (lblock - sblock) / 2 + sblock - 1) > X) * X + ((i * sblock + 23) <= X) * (i * sblock + (lblock - sblock) / 2 + sblock - 1); 
        y1 = ((j * sblock + (lblock - sblock) / 2 + sblock - 1) > Y) * Y + ((j * sblock + 23) <= Y) * (j * sblock + (lblock - sblock) / 2 + sblock - 1); 
        % 当前大块
        block_l = I(x0: x1, y0: y1);
        block_l = abs(fftshift(fft2(block_l)));
        % 对FFT结果进行排序
        mean_FFT = mean(block_l);
        [block_sorted, index] = sort(block_l(:), 'descend');
        [u, v] = ind2sub(size(block_l), index(2));
        [m, n] = ind2sub(size(block_l), index(3));
        if u == m && v == n
            Direction(i + 1, j + 1) = 0;
            Frequency(i + 1, j + 1) = 0;
        else
            Direction(i + 1, j + 1) = atan2((n - v), (m - u));
            Frequency(i + 1, j + 1) = sqrt(((n - v) / 2) ^ 2 + ((m - u) / 2)^ 2);
            temp = (block_l - mean_FFT);
            Variance(i + 1, j + 1) = var(temp(:));
        end
        if (Frequency(i + 1, j + 1) > 2 && Frequency(i + 1, j + 1) < 6)
            Flag(i + 1, j + 1) = 1;
        end
    end
end
% figure(1), imshow(Flag, 'InitialMagnification', 'fit')
% figure(2), imshow(Frequency, 'InitialMagnification', 'fit')
% figure(3), imshow(Direction, 'InitialMagnification', 'fit')

%% 对方向频率图空域平滑滤波
Direction = 2 * Direction;
low_pass_gaussion = fspecial('gaussian', [5, 5], 7);
low_pass_average = fspecial('average', 5);
Anglecos_f = imfilter(cos(Direction), low_pass_gaussion);
Anglesin_f = imfilter(sin(Direction), low_pass_gaussion);
Direction = 0.5 * atan2(Anglesin_f, Anglecos_f);
Frequency
