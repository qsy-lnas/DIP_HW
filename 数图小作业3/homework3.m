%% 数字图像处理第三次作业
clear; 
clc;
close all;
image_dir = '106_3.bmp'; % 源图片路径
file_type = '.bmp'; % 图片文件类型为bmp
% other global variable
sblock = 16;
lblock = 32;

%% Initial the image and others
Image = imread(image_dir);
[X, Y] = size(Image);
Direction = zeros(ceil(X / sblock), ceil(Y / sblock));
Period = zeros(ceil(X / sblock), ceil(Y / sblock));

%% calculate large block location
for i = 0 : ceil(X / sblock) - 1
    for j = 0 : ceil(Y / sblock) - 1
        % 计算以16*16小块为中心的32*32大块的左上右下点坐标，注意不要超出边界
        x0 = ((i * sblock - 8) < 1) + ((i * sblock - 8) >= 1) * (i * sblock - 8); % 左上角x坐标
        y0 = ((j * sblock - 8) < 1) + ((j * sblock - 8) >= 1) * (j * sblock - 8); % 左上角x坐标
        x1 = ((i * sblock + 23) > height) * height + ((i * sblock + 23) <= height) * (i * sblock + 23); % 右下角x坐标
        y1 = ((j * sblock + 23) > width) * width + ((j * sblock + 23) <= width) * (j * sblock + 23); % 右下角y坐标

    end
end