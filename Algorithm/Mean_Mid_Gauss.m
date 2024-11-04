clear;
clc;

% 读取彩色图像
I = imread('Moon.jpg','jpg');
OutImg = I;

% 分离RGB通道
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

%% 中值滤波
R_med = medfilt2(R, [3, 3]);
G_med = medfilt2(G, [3, 3]);
B_med = medfilt2(B, [3, 3]);
I1 = cat(3, R_med, G_med, B_med);  % 合并滤波后的通道

%% 均值滤波
R_avg = filter2(fspecial('average', 3), R) / 255;
G_avg = filter2(fspecial('average', 3), G) / 255;
B_avg = filter2(fspecial('average', 3), B) / 255;
I2 = cat(3, R_avg, G_avg, B_avg);  % 合并滤波后的通道

%% 高斯滤波
% 定义高斯滤波参数
sigma = 2;
filter_size = 5;

% 生成自定义的高斯核
[x, y] = meshgrid(-floor(filter_size/2):floor(filter_size/2), -floor(filter_size/2):floor(filter_size/2));
h = exp(-(x.^2 + y.^2) / (2 * sigma^2));
h = h / sum(h(:)); % 正则化滤波器，使其总和为1

% 对每个颜色通道分别应用高斯滤波
R_gauss = imfilter(R, h, 'replicate');
G_gauss = imfilter(G, h, 'replicate');
B_gauss = imfilter(B, h, 'replicate');
I3 = cat(3, R_gauss, G_gauss, B_gauss);  % 合并滤波后的通道

%% 显示结果
figure;
subplot(2, 2, 1), imshow(I), title('原图');
subplot(2, 2, 2), imshow(I1), title('中值滤波');
subplot(2, 2, 3), imshow(I2), title('均值滤波');
subplot(2, 2, 4), imshow(I3), title('高斯滤波');
