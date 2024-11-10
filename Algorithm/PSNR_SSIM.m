function [psnr_value, ssim_value] = calculate_psnr_ssim_resample(original_image, scaled_image)
    % 读取图像
    if ischar(original_image)
        original_image = imread(original_image);
    end
    if ischar(scaled_image)
        scaled_image = imread(scaled_image);
    end
    % 将图像转换为灰度图像（如果是彩色图像）
    if size(original_image, 3) == 3
        original_image = rgb2gray(original_image);
    end
    if size(scaled_image, 3) == 3
        scaled_image = rgb2gray(scaled_image);
    end
    % 获取两幅图像的尺寸
    [M, N] = size(original_image);
    [m, n] = size(scaled_image);
    % 判断缩放图像的尺寸，并执行上采样或下采样
    if m < M || n < N
        % 缩放图像较小，上采样到原始图像大小
        scaled_resampled = imresize(scaled_image, [M, N]);
        comparison_image = original_image;  % 用于对比的图像仍是原始图像
    elseif m > M || n > N
        % 缩放图像较大，下采样原始图像到缩放图像大小
        comparison_image = imresize(original_image, [m, n]);
        scaled_resampled = scaled_image;  % 用于对比的图像是缩放后的图像
    else
        % 图像尺寸相同，直接对比
        scaled_resampled = scaled_image;
        comparison_image = original_image;
    end
    % 计算 PSNR
    psnr_value = psnr(comparison_image, scaled_resampled);
    fprintf('PSNR: %.2f dB\n', psnr_value);
    % 计算 SSIM
    ssim_value = ssim(comparison_image, scaled_resampled);
    fprintf('SSIM: %.4f\n', ssim_value);
end
[psnr_val, ssim_val] = calculate_psnr_ssim_resample('origin_img.png', 'processed_img.png');
