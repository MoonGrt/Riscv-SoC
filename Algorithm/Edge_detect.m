% 读取彩色图像
img = imread('Moon.jpg');

% 提取RGB通道
R = img(:, :, 1);
G = img(:, :, 2);
B = img(:, :, 3);

% 对每个通道进行边缘检测
% edgesR = edge(R, 'Canny');
% edgesG = edge(G, 'Canny');
% edgesB = edge(B, 'Canny');
edgesR = edge(R, 'Sobel');
edgesG = edge(G, 'Sobel');
edgesB = edge(B, 'Sobel');

% 将逻辑矩阵转换为 uint8，并放大到0-255范围
edgesColor = cat(3, uint8(edgesR) * 255, uint8(edgesG) * 255, uint8(edgesB) * 255);

% 显示原始图像和边缘检测结果
figure;
subplot(1, 2, 1), imshow(img), title('原始彩色图像');
subplot(1, 2, 2), imshow(edgesColor), title('彩色图像边缘检测结果');
