function [Final_Map] = L_RPCA_T_Solver_v5(Img_Seq)


[H, W, nFrames] = size(Img_Seq);


Prior_Weight = zeros(H, W, nFrames);
parfor k = 1:nFrames
    img = Img_Seq(:,:,k);
    I_top = imtophat(img, strel('disk', 15));
    [Ix, Iy] = gradient(I_top);
    h = fspecial('gaussian', [3 3], 1.0);
    Ix2 = imfilter(Ix.^2, h, 'replicate'); Iy2 = imfilter(Iy.^2, h, 'replicate'); Ixy = imfilter(Ix.*Iy, h, 'replicate');
    Trace = Ix2 + Iy2; Det = Ix2 .* Iy2 - Ixy.^2;
    Delta = sqrt(max(0, Trace.^2 - 4*Det)); 
    lam1 = (Trace + Delta) / 2; lam2 = (Trace - Delta) / 2;
    Corner = (lam1 .* lam2) ./ (lam1 + lam2 + 1e-6);
    Prior_Weight(:,:,k) = 1 ./ (mat2gray(Corner) + 0.3); 
end


PatchSize = 64; Step = 32;      
[grid_x, grid_y] = meshgrid(1:Step:W-PatchSize+1, 1:Step:H-PatchSize+1);
num_patches = numel(grid_x);
Counter_Map = zeros(H, W, nFrames); Sum_Map = zeros(H, W, nFrames);

for i = 1:num_patches
    c = grid_x(i); r = grid_y(i);
    Cube = Img_Seq(r:r+PatchSize-1, c:c+PatchSize-1, :);
    Weight_Cube = Prior_Weight(r:r+PatchSize-1, c:c+PatchSize-1, :);
    [ph, pw, pf] = size(Cube);
    D = reshape(Cube, [ph*pw, pf]); W_vec = reshape(Weight_Cube, [ph*pw, pf]);
    
    lambda = 1.2 / sqrt(max(ph*pw, pf));
    [~, S_patch] = solve_weighted_rpca(D, W_vec, lambda);
    
    S_cube = reshape(S_patch, [ph, pw, pf]);
    Sum_Map(r:r+PatchSize-1, c:c+PatchSize-1, :) = Sum_Map(r:r+PatchSize-1, c:c+PatchSize-1, :) + abs(S_cube);
    Counter_Map(r:r+PatchSize-1, c:c+PatchSize-1, :) = Counter_Map(r:r+PatchSize-1, c:c+PatchSize-1, :) + 1;
end

Sparse_Stack = Sum_Map ./ (Counter_Map + eps);


h_spatial = fspecial('gaussian', [3 3], 0.8);
h_temporal = reshape([0.5, 1.0, 0.5], [1, 1, 3]);
Smooth_Stack = imfilter(Sparse_Stack, h_spatial, 'replicate');
Energy_Stack = convn(Smooth_Stack, h_temporal, 'same');
Energy_Stack = mat2gray(Energy_Stack);


mean_E = mean(Energy_Stack(:)); std_E = std(Energy_Stack(:));
Binary_Volume = Energy_Stack > (mean_E + 3.0 * std_E);

CC = bwconncomp(Binary_Volume, 26);
stats = regionprops(CC, 'BoundingBox', 'PixelIdxList');

Final_Binary_Vol = false(size(Binary_Volume));
for i = 1:CC.NumObjects
    
    if stats(i).BoundingBox(6) >= 3
        Final_Binary_Vol(stats(i).PixelIdxList) = true;
    end
end


Final_Map = Sparse_Stack .* double(Final_Binary_Vol);
Final_Map = mat2gray(Final_Map);

end

function [L, S] = solve_weighted_rpca(D, W, lambda)
    [m, n] = size(D); Y=D; norm_two=norm(Y,2); norm_inf=norm(Y(:),inf)/lambda;
    dual_norm=max(norm_two, norm_inf); Y=Y/dual_norm; L=zeros(m,n); S=zeros(m,n);
    mu=1.25/norm_two; rho=1.5; max_iter=20; 
    for iter=1:max_iter
        temp=D-S+(1/mu)*Y; [U,Si,V]=svd(temp,'econ'); dS=diag(Si); svp=length(find(dS>1/mu));
        if svp>=1, dS=dS(1:svp)-1/mu; else, svp=1; dS=0; end; L=U(:,1:svp)*diag(dS)*V(:,1:svp)';
        temp=D-L+(1/mu)*Y; th=(lambda./mu).*W; S=max(0,temp-th)+min(0,temp+th);
        Z=D-L-S; Y=Y+mu*Z; if norm(Z,'fro')/norm(D,'fro')<1e-6, break; end; mu=min(mu*rho,1e10);
    end
end