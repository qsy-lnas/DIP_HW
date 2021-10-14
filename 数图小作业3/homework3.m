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
[M, N] = size(Image)
