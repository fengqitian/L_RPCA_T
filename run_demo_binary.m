function run_demo_binary()

clc; clear; close all;


rootDir   = fileparts(mfilename('fullpath'));
imagePath = fullfile(rootDir, '1', 'images');
maskPath  = fullfile(rootDir, '1', 'masks'); %#ok<NASGU> % 当前demo中未使用
savePath  = fullfile(rootDir, 'binary_results');

if ~exist(imagePath, 'dir')
    error('找不到图像路径: %s', imagePath);
end
if ~exist(savePath, 'dir')
    mkdir(savePath);
end


exts = {'*.bmp','*.png','*.jpg','*.jpeg','*.tif','*.tiff'};
imgFiles = [];
for i = 1:numel(exts)
    imgFiles = [imgFiles; dir(fullfile(imagePath, exts{i}))]; %#ok<AGROW>
end

if isempty(imgFiles)
    error('在 %s 中没有找到图像文件。', imagePath);
end


[~, idx] = sort({imgFiles.name});
imgFiles = imgFiles(idx);

firstImg = imread(fullfile(imagePath, imgFiles(1).name));
if ndims(firstImg) == 3
    firstImg = rgb2gray(firstImg);
end
firstImg = im2double(firstImg);
[H, W] = size(firstImg);

nFrames = numel(imgFiles);
Img_Seq = zeros(H, W, nFrames);

fprintf('共读取 %d 帧图像...\n', nFrames);

for k = 1:nFrames
    img = imread(fullfile(imagePath, imgFiles(k).name));
    if ndims(img) == 3
        img = rgb2gray(img);
    end
    img = im2double(img);

    if size(img,1) ~= H || size(img,2) ~= W
        error('第 %d 张图像尺寸不一致。', k);
    end

    Img_Seq(:,:,k) = img;
end


fprintf('开始运行 L_RPCA_T_Solver_v5...\n');
Final_Map = L_RPCA_T_Solver_v5(Img_Seq);
fprintf('算法运行完成。\n');


for k = 1:nFrames
    frameMap = Final_Map(:,:,k);

   
    BW = frameMap > 0;

    
    [~, baseName, ~] = fileparts(imgFiles(k).name);
    saveName = fullfile(savePath, [baseName, '_bin.png']);
    imwrite(uint8(BW)*255, saveName);
end

fprintf('二值结果已保存到: %s\n', savePath);


mid = ceil(nFrames/2);
figure('Name','Binary Demo','Color','w');
subplot(1,2,1);
imshow(Img_Seq(:,:,mid), []);
title(sprintf('Input Frame %d', mid));

subplot(1,2,2);
imshow(Final_Map(:,:,mid) > 0, []);
title(sprintf('Binary Result %d', mid));

end