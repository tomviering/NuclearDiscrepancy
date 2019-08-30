function K = comp_kernel(sigma, A, B )
% comp_kernel Computes the kernel matrix for the dataset A and B
% the kernel matrix size(K) = (objects in A, objects in B)
% sigma denotes the kernel bandwidth of the Gaussian kernel

if (nargin < 3)
    B = A;
end

D = comp_dist(B,A);
K = exp(-D/(2*sigma^2));

end
