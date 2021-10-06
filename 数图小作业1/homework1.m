% 数字图像处理第一次作业
clear; 
clc;
close all;
main_dir = 'keqing/'; % 源图片放置在images文件夹中
file_type = '.jpg'; % 图片文件类型为jpg
max_Y = 0;

%% 读取文件夹中文件，且做尺寸调整(保持长宽比) 统一图片到同一大小 （空白区域用黑色）。例如，所有图片均为 600 x 1000(max_Y) x 3
image_files = dir([main_dir,'*',file_type]);
len = length(image_files);
image_collect = cell(len); % 将resize后的图片放到该元胞数组中

%% read and resize and renew max_Y
for i = 1:len
    image_dir = [image_files(i).folder, '\', image_files(i).name];
    image_read = imread(image_dir);% read image
    image_read = im2double(image_read);%uint to double
    image_read = imresize(image_read, [600, nan]);% resize
    image_collect{i} = image_read;
    a = size(image_read);
    max_Y = max(max_Y, a(2));%renew max_Y
    %imshow(image_read);
end

%% fill the background with black
for i = 1:len
    a = size(image_collect{i});
    if a(2) == max_Y
        continue
    else
        back_bg = zeros(600, max_Y, 3); % black ground
        l = (max_Y / 2) - (a(2) / 2);
        back_bg(:, l : max_Y - l - 1, :) = image_collect{i}(:, :, :);% why this index contains both right and left! make my code not beautiful!
        image_collect{i} = back_bg;
        %imshow(back_bg);
    end    
end

%% 建立新文件夹（之后方便将保存的视频帧存到该文件夹中）
new_main_dir = 'video_images/';  %建立video_images文件夹
if ~exist(new_main_dir,'dir')
    mkdir(new_main_dir);
end

%% new figure window
figure (1);
set(gcf,'unit','centimeters','position',[5 5 20 20]); % [x_. y_,lenx,leny]
set(gca,'Position',[.2, .2, .7, .65]);

%% 从黑色背景到第一张图片 （淡入淡出，灰度变换类）（示例）
black_background = zeros(600, max_Y, 3);
image_idx = 1; % image_collect 的索引
save_idx = 1; % 保存视频帧的序号
for factor = 0:0.02:1
    black_background = image_collect{image_idx} * factor;
    % 临时查看动画效果
    %imshow(black_background);
    %pause(0.001);
    imwrite(black_background, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end
%% 棋盘格淡入淡出 （灰度变换类）
image_idx = 2;
block_size = 120;
block_index = zeros(600, max_Y);
for i = 1: 600 % generate block_index
    for j = 1: max_Y
        if (mod(idivide(int32(i), int32(block_size), 'floor'), 2) == ...
                mod(idivide(int32(j), int32(block_size), 'floor'), 2))
            block_index(i, j) = 1;
        else
        end
    end
end
%imshow(block_index)
image_gen = image_collect{image_idx - 1};
% image_gen = image_gen + image_collect{image_idx} .* block_index;
% imshow(image_gen .* ~block_index)
%stage one
for factor = 0: 0.04: 1
    image_gen = image_gen .* ~block_index + ...
        image_collect{image_idx} .* block_index * factor + ...
        image_collect{image_idx - 1} .* block_index * (1 - factor); 
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;    
%     imshow(image_gen);
%     pause(0.001);
end
%stage two
for factor = 0: 0.04: 1
    image_gen = image_gen .* block_index + ...
        image_collect{image_idx} .* ~block_index * factor + ...
        image_collect{image_idx - 1} .* ~block_index * (1 - factor);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
%     imshow(image_gen);
%     pause(0.001);
end

%% 按方向淡入淡出 （灰度变换类）
image_idx = 3;
block_index = 0 : 1 / 400 : 1;
block_index = [zeros(1, max_Y), block_index, ones(1, max_Y)];
block_size = 401;
for i = 1 : 20 :max_Y + block_size
    block_temp = block_index(max_Y + block_size - i + 2 : max_Y + block_size - i + 1 + max_Y);
    block_temp = repmat(block_temp, 600, 1);
    image_gen = image_collect{image_idx - 1} .* block_temp + ...
        image_collect{image_idx} .* (ones(600, max_Y) - block_temp);
%     imshow(image_gen);
%     pause(0.001);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end

%% 按方向淡入淡出 （灰度变换类）
image_idx = 4;
block_index = 0 : 1 / 400 : 1;
block_index = [zeros(1, max_Y), block_index, ones(1, max_Y)];
block_size = 401;
for i = max_Y + block_size : -20 :1
    block_temp = block_index(max_Y + block_size - i + 2 : max_Y + block_size - i + 1 + max_Y);
    block_temp = repmat(block_temp, 600, 1);
    image_gen = image_collect{image_idx} .* block_temp + ...
        image_collect{image_idx - 1} .* (ones(600, max_Y) - block_temp);
%     imshow(image_gen);
%     pause(0.001);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end

%% 溶解 （灰度变换类）
image_idx = 5;
image_gen = image_collect{image_idx - 1};
block_index = randperm(600 * max_Y);
block_size = 1;
for scale = 0.02 : 0.02 : 1
    while block_size < scale * 600 * max_Y
        [a, b] = ind2sub([600, max_Y], block_index(block_size));
        image_gen(a, b, :) = ...
            image_collect{image_idx}(a, b, :);
        block_size = block_size + 1;
    end
%     imshow(image_gen);
%     pause(0.001);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end

%% 缩放动画 （几何变化类）
image_idx = 6;
image_gen = image_collect{image_idx - 1};
for scale = 0.02: 0.02: 1
    image_temp = imresize(image_collect{image_idx}, scale);
    image_size = size(image_temp);
    l_x = idivide(int32(600 - image_size(1)), 2);
    l_y = idivide(int32(max_Y - image_size(2)), 2);
    if (l_x | l_y) == 0
        l_x = 1;l_y = 1;
    end
    image_gen(int32(l_x) : int32(l_x + image_size(1) - 1), int32(l_y) : int32(l_y + image_size(2) - 1), :) = image_temp;
%     imshow(image_gen);
%     pause(0.001);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end

%% 单页翻转动画 （几何变化类）
image_idx = 7;
image_idx = image_idx - 1;
for i = [max_Y : -20 : 20, 40 : 20 : max_Y] % stage 1
    image_gen = zeros(600, max_Y, 3);
    if i == 20
        image_idx = image_idx + 1;
    end
    image_temp = imresize(image_collect{image_idx}, [600, i]);
    l = idivide(int32(max_Y - i), int32(2));
    image_gen(:, l + 1 : l + i, :) = image_temp;
%     imshow(image_gen);
%     pause(0.001);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end

%% 平移动画 （几何变化类）
image_idx = 8;
block_index = [zeros(1, max_Y), ones(1, max_Y)];
for pos = 1 : 20 : max_Y + 1
    block_temp = block_index(pos : pos + max_Y - 1);
    block_temp = repmat(block_temp, 600, 1);
    image_gen = image_collect{image_idx} .* block_temp + ...
        image_collect{image_idx - 1} .* ~block_temp;
%     imshow(image_gen);
%     pause(0.001);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end

%% 平移动画 （几何变化类）
image_idx = 9;
block_index = [ones(1, max_Y), zeros(1, max_Y)];
for pos = max_Y + 1 : -20 : 1
    block_temp = block_index(pos : pos + max_Y - 1);
    block_temp = repmat(block_temp, 600, 1);
    image_gen = image_collect{image_idx} .* block_temp + ...
        image_collect{image_idx - 1} .* ~block_temp;
%     imshow(image_gen);
%     pause(0.001);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end

%% 旋转+缩放动画 （几何变化类）
image_idx = 10;
image_idx = image_idx - 1;
for scale = [1 : -0.02 : 0.02, 0.04 : 0.02 : 1] %stage 1
    image_gen = zeros(600, max_Y, 3);
    if scale == 0.02
        image_idx = image_idx + 1;
    end
    image_temp = imrotate(imresize(image_collect{image_idx}, scale), ...
        mod(int32(scale * 360), int32(360)), "bilinear", "loose");
    image_size = size(image_temp);
    if image_size(1) > 600
        l_x = idivide(int32(image_size(1) - 600), 2);
        image_size(1) = 600;
        image_temp = image_temp(l_x : l_x + 599, :, :);
    end
    if image_size(2) > max_Y
        l_y = idivide(int32(image_size(2) - max_Y), 2);
        image_size(2) = max_Y;
        image_temp = image_temp( : ,l_y : l_y + max_Y - 1, :);
    end
    l_x = idivide(int32(600 - image_size(1)), 2);
    l_y = idivide(int32(max_Y - image_size(2)), 2);
    if l_x == 0
        l_x = 1;
    end
    if l_y == 0
        l_y = 1;
    end
    image_gen(int32(l_x) : int32(l_x + image_size(1) - 1), ...
        int32(l_y) : int32(l_y + image_size(2) - 1), :) = image_temp;
%     imshow(image_gen);
%     pause(0.001);
    imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
    save_idx = save_idx + 1;
end

%% 把 new_main_dir 中存好的图片制作成视频
animation = VideoWriter('photo_album','MPEG-4');%待合成的视频(不仅限于avi格式)的文件路径
animation.Quality = 100;
animation.FrameRate = 30;
open(animation);
image_files = dir([new_main_dir,'*',file_type]);
len = length(image_files);
image_name = cell(len);
for i=1:len
    image_name{i} = image_files(i).name; 
    %使用imread 读取视频帧图片，并使用writeVideo函数制作成视频
    a = imread([new_main_dir,image_name{i}]);
    writeVideo(animation, a);
end
close(animation);





