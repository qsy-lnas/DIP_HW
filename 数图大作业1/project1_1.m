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
lblock = 32;
mblock = 4;

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
%Variance = zeros(M_pixel, N_pixel);
%Variance_ft = zeros(M_pixel, N_pixel);
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
        %Variance(i + 1, j + 1) = std2(block_l);
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
            %temp = (block_l - mean_FFT);
            %Variance_ft(i + 1, j + 1) = std2(block_l);
        end
        if (Frequency(i + 1, j + 1) > 2 && Frequency(i + 1, j + 1) < 6)
            Flag(i + 1, j + 1) = 1;
        end
    end
end
% figure(1), imshow(Flag, [], 'InitialMagnification', 'fit')
% figure(2), imshow(Frequency, 'InitialMagnification', 'fit')
% figure(3), imshow(Direction, 'InitialMagnification', 'fit')

%% 前背景分割
mask = ImgMask(I, image_id, mblock);
figure, imshow(mask)
if image_id == 2
    I = Bfilter(I);
end
I = double(I) .* double(mask);


%% 对方向频率图空域平滑滤波
% Direction = 2 * Direction;
% low_pass_gaussion = fspecial('gaussian', [5, 5], 7);
% low_pass_average = fspecial('average', 5);
% Anglecos_f = imfilter(cos(Direction), low_pass_gaussion);
% Anglesin_f = imfilter(sin(Direction), low_pass_gaussion);
% Direction = 0.5 * atan2(Anglesin_f, Anglecos_f);

%% 巴特沃斯滤波器（用于图2）
function result = Bfilter(img)
% 用于第二幅图
f = img;
[M, N] = size(img);
P = max(2 * [M N]);
D0=140; 
W=100;
n=2;

[DX, DY] = meshgrid(1:P, 1:P);
D = sqrt((DX-P/2-1).^2+(DY-P/2-1).^2);
H = 1./(1+((D.^2-D0^2)./(D*W+eps)).^(2*n));

F = fftshift(fft2(f,P,P));
G = F.*H;
g = real(ifft2(ifftshift(G)));
g = g(1:M,1:N);

%figure,imshow(H,[],'巴特沃斯滤波器');
%figure,imshow(g,[],'巴特沃斯滤波');
result = g;
end

%% 计算前背景分割图
function result = ImgMask(img, img_id, mask_size)
switch img_id
    case 1
        th_var = 0.1;
        th_var_ft = 0.95;
    case 2
        th_var = 0;
        th_var_ft = 0.5;
    case 3
        th_var = 0.1;
        th_var_ft = 0.9;
end
[M, N] = size(img);
mask = zeros(M, N); % mask图
mask_M = ceil(M / mask_size);
mask_N = ceil(N / mask_size);
v = zeros(mask_M, mask_N); % 空域方差图
v_ft = zeros(mask_M, mask_N); % 频域方差图
% 求方差
for i = 0: (mask_M - 1)
    for j = 0 : (mask_N - 1)
        x0 = ((i * mask_size) < 1) + ((i * mask_size) >= 1) * (i * mask_size);
        y0 = ((j * mask_size) < 1) + ((j * mask_size) >= 1) * (j * mask_size); 
        x1 = (((i + 1) * mask_size - 1) > M) * M + ...
            (((i + 1) * mask_size - 1) <= M) * ((i + 1) * mask_size - 1); 
        y1 = (((j + 1) * mask_size - 1) > N) * N + ...
            ((j + 1) * mask_size - 1 <= N) * ((j + 1) * mask_size - 1); 
        x = fftshift(fft2(img(x0:x1, y0:y1)));
        v(i + 1, j + 1) = std2(img(x0:x1, y0:y1));
        v_ft(i + 1, j + 1) = std2(x);
    end
end
%平滑方差图
v = Smooth(v);
v_ft = Smooth(v_ft);
%求极值用于归一化
v_max = max(max(v));
v_ft_max = max(max(v_ft));
v_min = min(min(v_ft));
v_ft_min = min(min(v_ft));
%归一化
v = (v - v_min) / (v_max - v_min);
v_ft  =(v_ft - v_ft_min) / (v_ft_max - v_ft_min);
%综合时域频域方差计算mask
for i = 0: ceil(M / mask_size) - 1
    for j = 0:ceil(N / mask_size) - 1
        x0 = ((i * mask_size) < 1) + ...
            ((i * mask_size) >= 1) * (i * mask_size); % 左上角x坐标
        y0 = ((j * mask_size) < 1) + ...
            ((j * mask_size) >= 1) * (j * mask_size); % 左上角x坐标
        x1 = (((i + 1) * mask_size - 1) > M) * M + ...
            (((i + 1) * mask_size - 1) <= M) * ((i + 1) * mask_size - 1); % 右下角x坐标
        y1 = (((j + 1) * mask_size - 1) > N) * N + ...
            ((j + 1) * mask_size - 1 <= N) * ((j + 1) * mask_size - 1); % 右下角y坐标
        if ((v(i + 1, j + 1) > th_var) && (v_ft(i + 1, j + 1) < th_var_ft))
            mask(x0: x1, y0: y1) = 1;
        end
    end
end
%使用形态学方法优化mask图
switch img_id
    case 1
        erode = 4;
        dilate = 5;
    case 2
        erode = 55;
        dilate = 60;
    case 3
        erode = 300;
        dilate = 300;
end
% 3先膨胀
if img_id == 3
    s = strel('disk', 10);
    mask =imdilate(mask, s);
end
s = strel('disk', erode);
mask = imerode(mask, s);% 腐蚀
s = strel('disk', dilate);
mask = imdilate(mask, s);% 膨胀
result = mask;
end

%% 平滑频率图
function result = Smooth(img)
gf = fspecial('gaussian', [5, 5], 1);
result = imfilter(img, gf, 'replicate', 'same');
end