
clear all;

n = 50;
d = 1000;
X = randn(n,d);
wstar = rand(d,1);
y = X*wstar;
lambda = 0.1;

% different way to write reweighting
Xtilde = sqrt(1/n)*X;
ytilde = sqrt(1/n)*y;

% classical form
west = inv(Xtilde'*Xtilde + lambda*eye(d))*(Xtilde'*ytilde);
yhat_primal = Xtilde*west;

% kernel form
K = X*X';
yhat_kernel = K*inv(K + lambda*eye(n))*ytilde;

% using the function
alpha = krr_train(K, y, lambda);
yhat_krr = krr_test(K, alpha);

[yhat_primal*sqrt(n),yhat_kernel*sqrt(n),yhat_krr] % invert transform on y
