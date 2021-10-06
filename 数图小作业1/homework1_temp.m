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
    image_size = size(image_read);
    max_Y = max(max_Y, image_size(2));%renew max_Y
    %imshow(image_read);
end

%% fill the background with black
for i = 1:len
    image_size = size(image_collect{i});
    if image_size(2) == max_Y
        continue
    else
        back_bg = zeros(600, max_Y, 3); % black ground
        l = (max_Y / 2) - (image_size(2) / 2);
        back_bg(:, l : max_Y - l - 1, :) = image_collect{i}(:, :, :);% why this index contains both right and left! make my code not beautiful!
        image_collect{i} = back_bg;
        %imshow(back_bg);
    end    
end

%% 建立新文件夹（之后方便将保存的视频帧存到该文件夹中）
new_main_dir = 'video_debug/';  %建立video_images文件夹
if ~exist(new_main_dir,'dir')
    mkdir(new_main_dir);
end

%% new figure window
figure (1);
set(gcf,'unit','centimeters','position',[5 5 20 20]); % [x_. y_,lenx,leny]
set(gca,'Position',[.2, .2, .7, .65]);
save_idx = 1;

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
    imshow(image_gen);
    pause(0.001);
%     imwrite(image_gen, [new_main_dir, num2str(save_idx,'%05d'),file_type]);
%     save_idx = save_idx + 1;
end

