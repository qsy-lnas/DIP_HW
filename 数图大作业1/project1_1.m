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
sblock = 8;
lblock = 32;
mblock = 4;

%% Initial proccess
switch image_id
    case 1
        I = imread(image1_dir);
        I = padarray(I, [3, 3], 255);
    case 2
        I = imread(image2_dir);
        [M, N] = size(I);
        I = I(40:M, 40:N);
    case 3
        I = imread(image3_dir);
end
[M, N] = size(I);
M_pixel = floor(M / sblock);
N_pixel = floor(N / sblock);
% 3*3均值滤波
%I = imfilter(I, fspecial('average', [3, 3]));
I = I(2:M - 1, 2:N - 1);
% 填充图像
I = im2double(I);
%I_padding = padarray(I, [(lblock - sblock) / 2,...
%    (lblock - sblock) / 2], 255);
[X, Y] = size(I);

%% 前背景分割
mask = ImgMask(I, image_id, mblock);
%figure, imshow(I, [])%
if image_id == 2
    I = Bfilter(I); % 巴特沃斯滤波
end

%figure, imshow(I, [])%
I = double(I) .* double(mask); % 合并mask图
%figure, imshow(I, [])%
if image_id == 2
    %I = double(LocalHistEq(im2uint8(I))) .* double(mask);
else
    I = histeq(uint16(im2gray(I)));
end
%figure, imshow(I, [])
%获取方向频率图
[Direction, Frequency] = cal_df(I, image_id, lblock, sblock);
%分别光滑滤波
Direction = Smooth_d(Direction);
Frequency = Smooth(uint8(255 / max(max(Frequency)) * Frequency));
I = Enhance(I, Direction, Frequency, image_id, sblock, lblock);
figure, imshow(I)

%% 对原图进行图像增强
function result = Enhance(img, dirc, freq, img_id, sblock, lblock)
[M, N] = size(img);
switch img_id
    case 1
        th = 120;
        a = 600;
        b = 4;
    case 2
        th = 60;
        a = 600;
        b = 4;
    case 3
        th = 60;
        a = 600;
        b = 4;
end
mg = zeros(M, N);
ph = zeros(M, N);
for i = 0: ceil(M / sblock) - 1
    for j = 0: ceil(N / sblock) - 1
        x0 = ((i * sblock - (lblock - sblock) / 2) < 1) + ((i * sblock - (lblock - sblock) / 2) >= 1) * (i * sblock - (lblock - sblock) / 2); 
        y0 = ((j * sblock - (lblock - sblock) / 2) < 1) + ((j * sblock - (lblock - sblock) / 2) >= 1) * (j * sblock - (lblock - sblock) / 2); 
        x1 = ((i * sblock + (lblock - sblock) / 2 + sblock - 1) > M) * M + ((i * sblock + 23) <= M) * (i * sblock + (lblock - sblock) / 2 + sblock - 1); 
        y1 = ((j * sblock + (lblock - sblock) / 2 + sblock - 1) > N) * N + ((j * sblock + 23) <= N) * (j * sblock + (lblock - sblock) / 2 + sblock - 1);         
        block = img(x0: x1, y0: y1);
        if freq(i + 1, j + 1) > th
            [mg(x0 : x1, y0 : y1), ph(x0: x1, y0 : y1)] = imgaborfilt(block, a / freq(i + 1, j + 1) + b, dirc(i + 1, j + 1));
            block = mg(x0 : x1, y0: y1) .* cos(ph(x0 : x1, y0 : y1));
            % 取中心
            result(i * sblock + 1 : i * sblock + sblock, j * sblock + 1 : j * sblock + sblock) = block((lblock - sblock) / 2 + 1 : (lblock - sblock) / 2 + sblock); 
            % 归一化
            r_max = max(max(result(i * sblock + 1: i * sblock + sblock, j * sblock + 1 : j * sblock + sblock)));
            r_min = min(min(result(i * sblock + 1: i * sblock + sblock, j * sblock + 1 : j * sblock + sblock)));
            result(i * sblock + 1: i * sblock + sblock, j * sblock + 1 : j * sblock + sblock) = ...
                (result(i * sblock + 1: i * sblock + sblock, j * sblock + 1 : j * sblock + sblock) - r_min) / (r_max - r_min);
        else
            result(i * sblock + 1: i * sblock + sblock, j * sblock + 1 : j * sblock + sblock) = 0;
        end
    end
end

end
%% 求方向频率图
function [Direction, Frequency] = cal_df(img, img_id, lblock, sblock)
[M, N] = size(img);
switch img_id
    case 1
        th = 5 * 10^3;
    case 2
        th = 2 * 10^3;
    case 3
        th = 2 * 10^3;
end
% 方向矩阵，分辨率为8
Direction = zeros(ceil(M / sblock), ceil(N / sblock)); 
Frequency = zeros(ceil(M / sblock), ceil(N / sblock)); % 频率
for i = 0:ceil(M / sblock) - 1
    for j = 0:ceil(N / sblock) - 1
        x0 = ((i * sblock - (lblock - sblock) / 2) < 1) + ((i * sblock - (lblock - sblock) / 2) >= 1) * (i * sblock - (lblock - sblock) / 2); 
        y0 = ((j * sblock - (lblock - sblock) / 2) < 1) + ((j * sblock - (lblock - sblock) / 2) >= 1) * (j * sblock - (lblock - sblock) / 2); 
        x1 = ((i * sblock + (lblock - sblock) / 2 + sblock - 1) > M) * M + ((i * sblock + 23) <= M) * (i * sblock + (lblock - sblock) / 2 + sblock - 1); 
        y1 = ((j * sblock + (lblock - sblock) / 2 + sblock - 1) > N) * N + ((j * sblock + 23) <= N) * (j * sblock + (lblock - sblock) / 2 + sblock - 1);         
        block = img(x0:x1, y0:y1);
        block = abs(fftshift(fft2(block))); % 幅度谱
        
        if img_id ~= 2 % 图2无直流
            [x, y] = find(block == max(max(block))); 
            block(x,y) = 0; 
        end
        
        [~, pos] = sort(block(:), 'descend');
        [x1, y1] = ind2sub(size(block), pos(1));
        [x2, y2] = ind2sub(size(block), pos(2));
        
        if block(x1, y1) > th
            Direction(i + 1, j + 1) = atand((y1 - y2) / (x1 - x2)); % 方向值，取arctan
            Frequency(i + 1, j + 1) = sqrt((y1 - y2)^2 + (x1 - x2)^2) / 2 / pi; % 频率与距离成正比
        else
            Direction(i + 1, j + 1) = 180; % 方向值，取arctan
            Frequency(i + 1, j + 1) = 0; % 频率值
        end
    end
end
end

%% 局部直方图均衡(用于图2) from teacher
function result = LocHistEq(img)
I = img;
% 局部直方图均衡化
if 1
    n = 1;% neighborhood size (2*n+1)*(2*n+1)
    J2 = I;
    [H, W] = size(I);
    for r = 1+n:H-n
        for c = 1+n:W-n
            local_image = I(r-n:r+n,c-n:c+n);
            new_local_image = histeq(local_image);
            J2(r,c) = new_local_image(n+1,n+1);
        end
    end
    result = J2;
end
end

%% 巴特沃斯滤波器（用于图2）from teacher
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
        erode = 10;
        dilate = 15;
    case 2
        th_var = 0.12;
        th_var_ft = 0.60;
        erode = 22;
        dilate = 39;
    case 3
        th_var = 0.1;
        th_var_ft = 0.9;
        erode = 300;
        dilate = 300;
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
v_min = min(min(v));
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
% 3先膨胀
if img_id == 3
    s = strel('disk', 10);
    mask =imdilate(mask, s);
end
s = strel('disk', erode);
mask = imerode(mask, s);% 腐蚀
s = strel('disk', dilate);
mask = imdilate(mask, s);% 膨胀
if img_id == 2
    mask_ = zeros(M, N);
    mask_(200: 545, 170: 550) = mask(200: 545, 170: 550);
    mask = mask_;
end
result = mask;
end

%% 平滑方向图
function result = Smooth_d(img)
result = img .* pi ./ 90;
sine = sin(result);
cosine = cos(result); % 分别求正余弦
g_filter = fspecial('gaussian', [5, 5], 1);
sine = imfilter(sine, g_filter, 'replicate', 'same');
cosine = imfilter(cosine, g_filter, 'replicate', 'same'); % 分别光滑滤波
result = atan2(sine, cosine) ./ pi .* 90 + 90; % 转回角度制
end
%% 平滑频率图
function result = Smooth(img)
gf = fspecial('gaussian', [5, 5], 1);
result = imfilter(img, gf, 'replicate', 'same');
end