%% 数字图像处理第五次作业
clear; 
clc;
close all;
% choose fig
id = 3; % 1, 2, 3 
% other global variables
threshold = [0.4943, 0.496, 0.499];
epoch = [4 6 5];
l = [8 12 7];
disk = [3, 4, 5];
B(:, :, 1) = [0 0 0;1 1 0;0 0 0];
B(:, :, 2) = [0 0 0;0 1 0;0 1 0];
B(:, :, 3) = [0 0 0;0 1 1;0 0 0];
B(:, :, 4) = [0 1 0;0 1 0;0 0 0];
B(:, :, 5) = [1 0 0;0 1 0;0 0 0];
B(:, :, 6) = [0 0 0;0 1 0;1 0 0];
B(:, :, 7) = [0 0 0;0 1 0;0 0 1];
B(:, :, 8) = [0 0 1;0 1 0;0 0 0];
E(:, :, 1) = [ 0 -1 -1;  1  1 -1;  0 -1 -1];
E(:, :, 2) = [-1 -1 -1; -1  1 -1;  0  1  0];
E(:, :, 3) = [-1 -1  0; -1  1  1; -1 -1  0];
E(:, :, 4) = [ 0  1  0; -1  1 -1; -1 -1 -1];
E(:, : ,5) = [ 1 -1 -1; -1  1 -1; -1 -1 -1];
E(:, :, 6) = [-1 -1 -1; -1  1 -1;  1 -1 -1];
E(:, :, 7) = [-1 -1 -1; -1  1 -1; -1 -1  1];
E(:, :, 8) = [-1 -1  1; -1  1 -1; -1 -1 -1];

%% Part0 Img pre process
img = imread(['r' num2str(id) '.bmp']);
mask = immask(img, id);
img = im2double(img);
figure, imshow(img), title('Origin Figure')
% figure, imshow(mask), title('Mask')


%% Part1 脊线分割
% 二值化
img = Binarize(img, threshold(id));
%figure, imshow(img), title('二值化')
% 形态学运算
img = imresize(img, 4, 'nearest');
se1 = strel('disk', disk(id));
se2 = [0, 1, 0; 1, 1, 1; 0, 1, 0];
img = imopen(img, se1);
img = imdilate(img, se2);
imclose(img, se1);
img = imresize(img, 0.25, 'bilinear');
img = im2double(img);
img = Binarize(img, threshold(id));
img = ~bwareaopen(~img, 8, 4);
figure, imshow(img), title('形态学运算')

%% Part2 脊线细化
% 形态学细化
img = bwmorph(img, 'thin', inf);
img = bwskel(img);
%figure, imshow(img), title('脊线细化')
% 细化后处理
cnt = 0;
x1 = img;
while(cnt < epoch(id))
    x1 = x1 - (horm(x1, B(:, :, 1), ~B(:, :, 1)));
    x1 = x1 - (horm(x1, B(:, :, 2), ~B(: ,: ,2)));
    x1 = x1 - (horm(x1, B(: ,: ,3), ~B(: ,: ,3)));
    x1 = x1 - (horm(x1, B(: ,:, 4), ~B(: ,:, 4)));
    x1 = x1 - (horm(x1, B(:, :, 5), ~B(: ,: ,5)));
    x1 = x1 - (horm(x1, B(: ,: ,6), ~B(: ,: ,6)));
    x1 = x1 - (horm(x1, B(: ,:, 7), ~B(: ,: ,7)));
    x1 = x1 - (horm(x1, B(: ,: ,8), ~B(: ,:, 8)));
    cnt = cnt + 1;
end
cnt = 0;
x2 = horm(x1, B(: , :, 1), ~B(: ,: ,1)) | ...
    horm(x1, B(: ,:, 2), ~B(:, :, 2)) | ...
    horm(x1, B(: ,:, 3), ~B(:, :, 3)) | ...
    horm(x1, B(: ,:, 4), ~B(:, :, 4)) | ...
    horm(x1, B(:, :, 5), ~B(:, :, 5)) | ...
    horm(x1, B(:, :, 6), ~B(:, :, 6)) | ...
    horm(x1, B(:, :, 7), ~B(:, :, 7)) | ...
    horm(x1, B(: ,:, 8), ~B(:, :, 8));
x3 = imdilate(x2, strel('square', 3));
while(cnt < epoch(id))
    x3 = imdilate(x3, strel('square', 3)) & img;
    cnt = cnt + 1;
end
img = x1 | x3;

figure, imshow(img), title('细化后处理')
% 消短线
img = bwareaopen(img, 4, 8);
[M, N] = size(img);
hit = img;
for i = 1: l(id) % 消减长度维l
    temp = hit;
    for j = 1: size(E)
        e = E(:, :, 1);
        e = squeeze(e);
        p = bwhitmiss(hit, e);
        temp = bitand(temp, (1 - p));
    end
    hit = temp;
end
%figure, imshow(hit), title('消短线-修剪')

ends = bwmorph(hit, 'endpoints', inf);
se = strel('square', 3);
dilate = imdilate(ends, se);
for i = 1: l(id) - 1
    dilate = bitand(dilate, img);
    dilate = imdilate(dilate, se);
end
dilate = bitand(dilate, img);
img = bitor(dilate, hit);
%figure, imshow(img), title('消短线-膨胀')
% 分叉点消短线
branches = zeros(0, 2); % 分叉点
for i = 2: M - 1
    for j = 2 : N - 1
        if img(i, j) == 1
            x1 = i - 1;
            x2 = i + 1;
            y1 = j - 1;
            y2 = j + 1;
            br = (abs(img(x1, j) - img(x1, y1)) + ...
                abs(img(x1, y2) - img(x1, j)) + ...
                abs(img(i, y2) - img(x1, y2)) + ...
                abs(img(x2, y2) - img(i, y2)) + ...
                abs(img(x2, j) - img(x2, y2)) + ...
                abs(img(x2, y1) - img(x2, j)) + ...
                abs(img(i, y1) - img(x2, y1)) + ...
                abs(img(x1, y1) - img(i, y1))) / 2;
            if br == 3
                branches = [branches; i j]; %#ok<AGROW> 
            end
        end
    end
end

%% 结合分叉点去短线
for i = 1 : size(branches)
    img(branches(i, 1), branches(i, 2)) = 0;
end
img = bwareaopen(img, 4, 8);
for i = 1 : size(branches)
    img(branches(i, 1), branches(i, 2)) = 1;
end
img = bwareaopen(img, 4, 8);
figure, imshow(img), title('消短线')

%% 细节点检测
ends = zeros(0, 2); % 端点
branches = zeros(0, 2); % 分叉点
for i = 2: M - 1
    for j = 2 : N - 1
        if img(i, j) == 1
            x1 = i - 1;
            x2 = i + 1;
            y1 = j - 1;
            y2 = j + 1;
            br = (abs(img(x1, j) - img(x1, y1)) + ...
                abs(img(x1, y2) - img(x1, j)) + ...
                abs(img(i, y2) - img(x1, y2)) + ...
                abs(img(x2, y2) - img(i, y2)) + ...
                abs(img(x2, j) - img(x2, y2)) + ...
                abs(img(x2, y1) - img(x2, j)) + ...
                abs(img(i, y1) - img(x2, y1)) + ...
                abs(img(x1, y1) - img(i, y1))) / 2;
            if br == 1
                ends = [ends; i j]; %#ok<AGROW> 
            end
            if br == 3
                branches = [branches; i j]; %#ok<AGROW> 
            end
        end
    end
end
img = im2double(img);
fulimg = img;
for i = 1: size(ends)
    fulimg = insertShape(fulimg, 'circle', [ends(i, 2), ends(i, 1), 4], 'LineWidth', 1, 'Color', 'red');
end
for i = 1: size(branches)
    fulimg =  insertShape(fulimg, 'circle', [branches(i, 2), branches(i, 1), 4], 'LineWidth', 1, 'Color', 'yellow');
end
figure, imshow(fulimg), title('细节点检测')

%% 细节点验证
% 端点
for i = 1: size(ends)
    flag = 1;
    x0 = ends(i, 1) - 3;
    x1 = ends(i, 1) + 3;
    y0 = ends(i, 2) - 3;
    y1 = ends(i, 2) + 3;
    % 删去边缘点
    if sum(sum(mask(x0 : x1, y0 : y1))) < 40
        flag = 0;
    end
    % 删去断线端点
    [idx, ~] = find(abs(ends(:, 1) - ends(i, 1)) <= 6);
    [idy, ~] = find(abs(ends(:, 2) - ends(i, 2)) <= 6);
    if sum(intersect(idx, idy)) - i > 0
        flag = 0;
    end
    % 删去假端点
    for x = x0 : x1
        for y = y0 : y1
            [idx, ~] = find(branches(:, 1) == x);
            if branches(idx, 2) == y
                flag = 0;
                break
            end
        end
    end
    if flag
        img = insertShape(img, 'circle', [ends(i, 2), ends(i, 1), 4], 'LineWidth', 1, 'Color', 'red');
    end
end
% 分叉点
for i = 1 : size(branches)
    flag = 1;
    x0 = branches(i, 1) - 3;
    x1 = branches(i, 1) + 3;
    y0 = branches(i, 2) - 3;
    y1 = branches(i, 2) + 3;
    % 删去边缘点
    if sum(sum(mask(x0 : x1, y0 : y1))) < 40
        flag = 0;
    end
    % 删去假分叉点
    for x = x0 : x1
        for y = y0 : y1
            [idx, ~] = find(ends(:, 1) == x);
            for j = 1 : size(idx)
                if ends(idx(j), 2) == y
                    flag = 0
                    break
                end
            end
%             if ends(idx, 2) == y
%                 flag = 0;
%                 break
%             end
        end
    end
    if flag
        img = insertShape(img, 'circle', [branches(i, 2), branches(i, 1), 4], 'LineWidth', 1, 'Color', 'yellow');
    end
end
figure, imshow(img), title('细节点验证')


%% 二值化
function result = Binarize(img, th)
    img = im2double(img);
    img(img > th) = 1;
    img(img <= th) = 0;
    result = img;
end

%% Hit or Miss
function result = horm(img, b1, b2)
    result1 = imerode(img, b1);
    result2 = imerode(~img, b2);
    result = result1 & result2;
end

%% 获取蒙版
function mask = immask(img, id)
    th = [126 124.5 126];
    in = [2 5 2];
    out = [18 25 25];
    if id == 2
        mask = 1 - (abs(img - th(id)) <= 1);
    else
        mask = 1 - (img == th(id));
    end
    mask = imdilate(mask, strel('disk', in(id)));
    mask = imerode(mask, strel('disk', out(id)));
end