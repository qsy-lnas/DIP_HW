finger_img = imread("106_3.bmp"); % 读取图像
figure(1); imshow(finger_img),title('方向图'); hold on
[height, width] = size(finger_img); % 获取图像长宽
direction = zeros(ceil(height / 16), ceil(width / 16)); % 方向矩阵，分辨率为1/16
period = direction; % 周期

for i = 0:ceil(height / 16) - 1
    for j = 0:ceil(width / 16) - 1
        % 计算以16*16小块为中心的32*32大块的左上右下点坐标，注意不要超出边界
        x0 = ((i * 16 - 8) < 1) + ((i * 16 - 8) >= 1) * (i * 16 - 8); % 左上角x坐标
        y0 = ((j * 16 - 8) < 1) + ((j * 16 - 8) >= 1) * (j * 16 - 8); % 左上角x坐标
        x1 = ((i * 16 + 23) > height) * height + ((i * 16 + 23) <= height) * (i * 16 + 23); % 右下角x坐标
        y1 = ((j * 16 + 23) > width) * width + ((j * 16 + 23) <= width) * (j * 16 + 23); % 右下角y坐标
        
        block = finger_img(x0:x1, y0:y1);
        A = abs(fftshift(fft2(block))); % 幅度谱
        
        [x, y] = find(A == max(max(A))); % 找到最大值的坐标
        while length(x) <= 1
            A(x, y) = 0;
            [x, y] = find(A == max(max(A))); % 认为是直流分量
        end
        if A(x(1), y(1)) > 5 * 10^3
            direction(i + 1, j + 1) = atand((y(1) - y(2)) / (x(1) - x(2))); % 方向值，取arctan
            period(i + 1, j + 1) = 4 / sqrt((y(1) - y(2))^2 + (x(1) - x(2))^2); % 周期值
        else
            direction(i + 1, j + 1) = 180; % 方向值，取arctan（DrawDir中越界）
            period(i + 1, j + 1) = 0; % 周期值
        end
        
    end
end
DrawDir(1, direction, 16, 'g');
period = uint8(255 / max(max(period)) * period); %映射到0-255
figure(2),
imshow(period, 'InitialMagnification','fit'), title('周期图');%