function alpha = krr_train(K, y, lambda)
% alpha = KRR_TRAIN(K, y, lambda)
% trains a kernel ridge regression model in a stable way
% K, train kernel
% y, train labels
% lambda, regularization parameter (\mu in the manuscript)

n = size(K,1);
L = chol(K + eye(n)*lambda*n); % multiply by n to get MSE
alpha = L\(L'\y);

end

% closed form taken from
% https://papers.nips.cc/paper/3075-correcting-sample-selection-bias-by-unlabeled-data.pdf
% under equation 8

% very stable computation
% taken from 
% http://www.gaussianprocess.org/gpml/chapters/RW2.pdf
% page 19
