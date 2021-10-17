%% 数字图像处理第三次作业
clear; 
clc;
close all;
image_dir = '106_3.bmp'; % 源图片路径
file_type = '.bmp'; % 图片文件类型为bmp
% other global variable
sblock = 16;
lblock = 30;

%% Initial the image and others
Image = imread(image_dir);
figure(1), imshow(Image);
[X, Y] = size(Image);
Direction = zeros(ceil(X / sblock), ceil(Y / sblock));
Period = zeros(ceil(X / sblock), ceil(Y / sblock));
ROI = zeros(ceil(X / sblock), ceil(Y / sblock));
%% calculate large block location
for i = 0 : ceil(X / sblock) - 1
    for j = 0 : ceil(Y / sblock) - 1
        % 计算以小块为中心的大块的边际点坐标+特判
        x0 = ((i * sblock - (lblock - sblock) / 2) < 1) + ((i * sblock - (lblock - sblock) / 2) >= 1) * (i * sblock - (lblock - sblock) / 2); 
        y0 = ((j * sblock - (lblock - sblock) / 2) < 1) + ((j * sblock - (lblock - sblock) / 2) >= 1) * (j * sblock - (lblock - sblock) / 2); 
        x1 = ((i * sblock + (lblock - sblock) / 2 + sblock - 1) > X) * X + ((i * sblock + 23) <= X) * (i * sblock + (lblock - sblock) / 2 + sblock - 1); 
        y1 = ((j * sblock + (lblock - sblock) / 2 + sblock - 1) > Y) * Y + ((j * sblock + 23) <= Y) * (j * sblock + (lblock - sblock) / 2 + sblock - 1); 
        block_l = Image(x0: x1, y0: y1);
        block_l = block_l - mean(mean(block_l));
        if mean(mean(block_l)) <= 3
            ROI(i + 1, j + 1) = 0;
            Period(i + 1, j + 1) = 0;
            continue;
        end
        %imshow(block_l)
        
        block_l = abs(fftshift(fft2(block_l)));
        while 1
            [x, y] = find(block_l == max(max(block_l)));
            if length(x) > 1
                break;
            else 
                block_l(x, y) = 0;
            end
        end
        ROI(i + 1, j + 1) = 1;
        Direction(i + 1, j + 1) = atand((y(1) - y(2)) / (x(1) - x(2)));
        Period(i + 1, j + 1) = 1 / sqrt((y(1) - y(2))^2 + (x(1) - x(2)) ^ 2);
%         [block_sorted, index] = sort(block_l(:), 'descend');
%         [u, v] = ind2sub(size(block_l), index(1));
%         [m, n] = ind2sub(size(block_l), index(2));
%         if u == m && v == n
%             Direction(i + 1, j + 1) = 0;
%             Period(i + 1, j + 1) = 0;
%             ROI(i + 1, j + 1) = 0;
%         else
%             ROI(i + 1, j + 1) = 1;
%             Direction(i + 1, j + 1) = atand((n - v) / (m - u));
%             Period(i + 1, j + 1) = 4 / sqrt((n - v) ^ 2 + (m - u) ^ 2);
%         end
    end
end
DrawDir(1, Direction, sblock, 'b', ROI);
Period = uint8(255 / max(max(Period)) * Period); %映射到0-255
figure(2),imshow(Period, 'InitialMagnification', 'fit');
%figure(3), imshow(Direction, 'InitialMagnification', 'fit');