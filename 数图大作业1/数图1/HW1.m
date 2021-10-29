global NUM; % 图像编号
global SIZE_block;
SIZE_block = 8; % 将原图分为小块的大小
%蒙版操作小块的大小
global SIZE_mask;
SIZE_mask = 4;

close all;

% 循环处理图像，保存处理好的图像为NUM_after.jpg
for NUM = 1:3
finger_img = imread(int2str(NUM) + ".bmp"); % 读取图像
%figure, imshow(finger_img, [], 'InitialMagnification','fit'), title('原图像');
[height, width] = size(finger_img); % 获取图像长宽

% 分割
mask = ForeImg(finger_img, height, width);

if NUM == 2
    f = finger_img;
    [M,N] = size(f);
    P = max(2*[M N]);% Padding size.
    
    D0=140; % 用于第二幅图
    W=100;
    n=2;
    H = bbpf(D0,W,n,P);
    
    
    [DX, DY] = meshgrid(1:P, 1:P);
    D = sqrt((DX-P/2-1).^2+(DY-P/2-1).^2);
    H = 1./(1+((D.^2-D0^2)./(D*W+eps)).^(2*n));
    
    F = fftshift(fft2(f,P,P));
    G = F.*H;
    g = real(ifft2(ifftshift(G)));
    g = g(1:M,1:N);

    %figure,imshow(H,[],'巴特沃斯滤波器');
    %figure,imshow(g,[],'巴特沃斯滤波');
    finger_img = g;
end

finger_img = double(finger_img) .* double(mask); % 乘以蒙版操作
%figure, imshow(finger_img, [], 'InitialMagnification','fit'), title('前景分割');

if NUM ~= 2
    finger_img = histeq(uint16(im2gray(finger_img))); % 直方图均衡化
else
    finger_img = double(LocalHistEq(im2uint8(finger_img))) .* double(mask); % 直方图均衡化
end
%figure, imshow(finger_img, 'InitialMagnification','fit'), title('直方图均衡化');

% 参数代表归一化显示和适合图窗尺寸
[direction, freq] = Get_Features(finger_img, height, width);
%figure, imshow(direction, [], 'InitialMagnification','fit'), title('初始计算的方向图');

direc_smooth = DirectionSmooth(direction);
%figure, imshow(direc_smooth, [], 'InitialMagnification','fit'), title('平滑后的方向图');

freq = uint8(255 / max(max(freq)) * freq); %映射到0-255
%figure, imshow(freq, 'InitialMagnification','fit'), title('初始计算的频率图');

freq_smooth = Smooth(freq);
%figure, imshow(freq_smooth, 'InitialMagnification','fit'), title('平滑后的频率图');

% 增强
finger_img_after = Enhance(finger_img, direc_smooth, freq_smooth, height, width);

name = int2str(NUM) + "_after.png";

imwrite(finger_img_after, int2str(NUM) + "_after.png");
end


% 计算前背景分割图，返回蒙版
% 输入参数为原图、长度宽度
function result = ForeImg(img, height, width)
global SIZE_mask;
global NUM;
I1 = im2double(img); % 原图，表示空域
I2 = I1; % 频域

switch NUM
    case 1
        threshold_var = 0.1;
        threshold_var_ft = 0.95;
    case 2
        threshold_var = 0;
        threshold_var_ft = 0.5;
    case 3
        threshold_var = 0.1;
        threshold_var_ft = 0.9;
end


var = zeros(ceil(height / SIZE_mask), ceil(width / SIZE_mask)); % 方差图
var_ft = var; % 频域方差
mask = zeros(height, width);
for i = 0:ceil(height / SIZE_mask) - 1
    for j = 0:ceil(width / SIZE_mask) - 1
        % 计算8*8小块的左上右下点坐标，注意不要超出边界
        x0 = ((i * SIZE_mask) < 1) + ...
            ((i * SIZE_mask) >= 1) * (i * SIZE_mask); % 左上角x坐标
        y0 = ((j * SIZE_mask) < 1) + ...
            ((j * SIZE_mask) >= 1) * (j * SIZE_mask); % 左上角x坐标
        x1 = (((i + 1) * SIZE_mask - 1) > height) * height + ...
            (((i + 1) * SIZE_mask - 1) <= height) * ((i + 1) * SIZE_mask - 1); % 右下角x坐标
        y1 = (((j + 1) * SIZE_mask - 1) > width) * width + ...
            ((j + 1) * SIZE_mask - 1 <= width) * ((j + 1) * SIZE_mask - 1); % 右下角y坐标
        I2(x0:x1, y0:y1) = fftshift(fft2(I1(x0:x1, y0:y1))); % 对该小块做傅里叶变换看频谱图
        var(i + 1, j + 1) = std2(I1(x0:x1, y0:y1)); % 空域方差
        var_ft(i + 1, j + 1) = std2(I2(x0:x1, y0:y1)); % 频域方差
    end
end
var = Smooth(var); % 平滑
var_ft = Smooth(var_ft);
mmax = max(max(var));
mmin = min(min(var));
var = (var - mmin) / (mmax - mmin); % 归一化
mmax = max(max(var_ft));
mmin = min(min(var_ft));
var_ft = (var_ft - mmin) / (mmax - mmin);
for i = 0:ceil(height / SIZE_mask) - 1
    for j = 0:ceil(width / SIZE_mask) - 1
        x0 = ((i * SIZE_mask) < 1) + ...
            ((i * SIZE_mask) >= 1) * (i * SIZE_mask); % 左上角x坐标
        y0 = ((j * SIZE_mask) < 1) + ...
            ((j * SIZE_mask) >= 1) * (j * SIZE_mask); % 左上角x坐标
        x1 = (((i + 1) * SIZE_mask - 1) > height) * height + ...
            (((i + 1) * SIZE_mask - 1) <= height) * ((i + 1) * SIZE_mask - 1); % 右下角x坐标
        y1 = (((j + 1) * SIZE_mask - 1) > width) * width + ...
            ((j + 1) * SIZE_mask - 1 <= width) * ((j + 1) * SIZE_mask - 1); % 右下角y坐标
        if ((var(i + 1, j + 1) > threshold_var) && (var_ft(i + 1, j + 1) < threshold_var_ft))
            mask(x0:x1, y0:y1) = 1;
        end
    end
end

%figure, imshow(var, [], 'InitialMagnification','fit'), title('空域方差图');
%figure, imshow(var_ft, [], 'InitialMagnification','fit'), title('频域方差图');
switch NUM
    case 1
        erode_size = 2;
        dilate_size = 5;
    case 2
        erode_size = 55;
        dilate_size = 60;
    case 3
        erode_size = 300;
        dilate_size = 300;
end
if NUM == 3
    se = strel('disk', 10); % 半径为5的圆盘型结构元素
    mask = imdilate(mask, se); % 膨胀
end
%figure, imshow(mask, [], 'InitialMagnification','fit'), title('二值化方差图');
se = strel('disk', erode_size); % 半径为5的圆盘型结构元素
mask_erode = imerode(mask, se); % 腐蚀
%figure, imshow(mask_erode, [], 'InitialMagnification','fit'), title('腐蚀操作');
se = strel('disk', dilate_size);
mask_dilate = imdilate(mask_erode, se); % 膨胀
%figure, imshow(mask_dilate, [], 'InitialMagnification','fit'), title('膨胀操作');
result = mask_dilate;
end



function [direction, freq] = Get_Features(img, height, width)
global SIZE_block;
global NUM;

switch NUM
    case 1
        A_threshold = 5 * 10^3;
    case 2
        A_threshold = 2 * 10^3;
    case 3
        A_threshold = 2 * 10^3;
end

% 方向矩阵，分辨率为1/8
direction = zeros(ceil(height / SIZE_block), ceil(width / SIZE_block)); 
freq = direction; % 频率
for i = 0:ceil(height / SIZE_block) - 1
    for j = 0:ceil(width / SIZE_block) - 1
    % 计算以8*8小块为中心的32*32大块的左上右下点坐标，注意不要超出边界
        x0 = ((i * SIZE_block - 8) < 1) + ...
            ((i * SIZE_block - 8) >= 1) * (i * SIZE_block - 8); % 左上角x坐标
        y0 = ((j * SIZE_block - 8) < 1) + ...
            ((j * SIZE_block - 8) >= 1) * (j * SIZE_block - 8); % 左上角x坐标
        x1 = ((i * SIZE_block + 23) > height) * height + ...
            ((i * SIZE_block + 23) <= height) * (i * SIZE_block + 23); % 右下角x坐标
        y1 = ((j * SIZE_block + 23) > width) * width + ...
            ((j * SIZE_block + 23) <= width) * (j * SIZE_block + 23); % 右下角y坐标
        
        block = img(x0:x1, y0:y1);
        A = abs(fftshift(fft2(block))); % 幅度谱
        
        if NUM ~= 2
            [x, y] = find(A == max(max(A))); % 找到正弦函数傅里叶幅度谱最大值的坐标
            A(x,y) = 0; % 直流分量
        end
        
        [a, pos] = sort(A(:), 'descend');
        [x1, y1] = ind2sub(size(A), pos(1));
        [x2, y2] = ind2sub(size(A), pos(2));
        
        %if A(x(1), y(1)) > A_threshold
        if A(x1, y1) > A_threshold
            %direction(i + 1, j + 1) = atand((y(1) - y(2)) / (x(1) - x(2))); % 方向值，取arctan
            direction(i + 1, j + 1) = atand((y1 - y2) / (x1 - x2)); % 方向值，取arctan
            %freq(i + 1, j + 1) = sqrt((y(1) - y(2))^2 + (x(1) - x(2))^2) / 2 / pi; % 频率与距离成正比
            freq(i + 1, j + 1) = sqrt((y1 - y2)^2 + (x1 - x2)^2) / 2 / pi; % 频率与距离成正比
        else
            direction(i + 1, j + 1) = 180; % 方向值，取arctan
            freq(i + 1, j + 1) = 0; % 频率值
        end
    end
end
end

% 方向图的平滑
function result = DirectionSmooth(D)
global NUM;

result = D .* pi ./ 90; % 转化为弧度制
D_sin = sin(result); % 接收弧度制
D_cos = cos(result);
Gaussian_filter = fspecial('Gaussian', [5,5], 1);
D_sin = imfilter(D_sin, Gaussian_filter, 'replicate', 'same');
D_cos = imfilter(D_cos, Gaussian_filter, 'replicate', 'same');
result = atan2(D_sin, D_cos) ./ pi .* 90 + 90; %转化回角度制，范围是0~180度
end

% 频率图的平滑
function result = Smooth(F)
Gaussian_filter = fspecial('Gaussian', [5,5], 1);
result = imfilter(F, Gaussian_filter, 'replicate', 'same');
end

% 图像增强，输入参数为原图，方向图，频率图，原图高度、宽度
function result = Enhance(img, direc, freq, height, width)
global SIZE_block;
global NUM;

switch NUM
    case 1
        freq_threshold = 120;
        a = 600;
        b = 4;
    case 2
        freq_threshold = 60;
        a = 600;
        b = 4;
    case 3
        freq_threshold = 60;
        a = 600;
        b = 4;
end

mag = zeros(height, width);
phase = zeros(height, width);
for i = 0:ceil(height / SIZE_block) - 1
    for j = 0:ceil(width / SIZE_block) - 1
        % 计算以8*8小块为中心的32*32大块的左上右下点坐标，注意不要超出边界
        x0 = ((i * SIZE_block - 8) < 1) + ...
            ((i * SIZE_block - 8) >= 1) * (i * SIZE_block - 8); % 左上角x坐标
        y0 = ((j * SIZE_block - 8) < 1) + ...
            ((j * SIZE_block - 8) >= 1) * (j * SIZE_block - 8); % 左上角x坐标
        x1 = ((i * SIZE_block + 23) > height) * height + ...
            ((i * SIZE_block + 23) <= height) * (i * SIZE_block + 23); % 右下角x坐标
        y1 = ((j * SIZE_block + 23) > width) * width + ...
            ((j * SIZE_block + 23) <= width) * (j * SIZE_block + 23); % 右下角y坐标
        block = img(x0:x1, y0:y1);
        if freq(i + 1, j + 1) > freq_threshold % 去掉无指纹的区域
            [mag(x0:x1, y0:y1), phase(x0:x1, y0:y1)] = imgaborfilt(block, a / freq(i + 1, j + 1) + b, direc(i + 1, j + 1));
            result(x0:x1, y0:y1) = mag(x0:x1, y0:y1) .* cos(phase(x0:x1, y0:y1));
            R_max = max(max(result(x0:x1, y0:y1)));
            R_min = min(min(result(x0:x1, y0:y1)));
            result(x0:x1, y0:y1) = (result(x0:x1, y0:y1) - R_min) / (R_max - R_min);
        else
            result(x0:x1, y0:y1) = 0;
        end
    end
end

% 高斯滤波平滑
%figure, imshow(result, [], 'InitialMagnification', 'fit'), title('平滑前的图像');
Gaussian_filter = fspecial('Gaussian', [8, 8], 1);
result = imfilter(result, Gaussian_filter, 'replicate', 'same');
result = imbinarize(result, 0.5);
%figure, imshow(mag, [], 'InitialMagnification', 'fit'), title('Gabor 滤波器的幅值响应');
%figure, imshow(phase, [], 'InitialMagnification', 'fit'), title('Gabor 滤波器的相位响应');

%figure, imshow(result, [], 'InitialMagnification', 'fit'), title('增强后的图像');
end