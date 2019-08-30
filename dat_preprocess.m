function dat = dat_preprocess(X,y,sigma_try,lambda_try,n_val,n_val_trn,repeats,n_threshold,dataset)
% this file preprocesses the data,
% for example, it sets the mean to zero and std to 1 for each feature,
% and gets the right hyperparameters
% 
% actually, since the paper has gone through several iterations, several
% things have changed... we dont use the validation samples anymore for
% example, they are not discarded anymore. the validation samples are also
% not anymore needed since we just look up the best hyperparameters below
% here.

n = length(y);

% correct mean and std of X
Xm = mean(X);
Xs = std(X);
Xs(Xs == 0) = 1;
X = X - Xm;
X = X./repmat(Xs,n,1);

% rescale so y is between -1 and 1
y = rescale(y)*2-1; 

% generate splits
rng(1);
ids = randperm(n);

% get validation data for hyper parameter selection
ids_val = ids(1:n_val);
ids_rest = ids(n_val+1:end);
X_val = X(ids_val,:);
y_val = y(ids_val);

fprintf('Validation set size: %d\n',size(X_val,1));

% get sensible values for sigma
%D = sqrt(comp_dist(X)); % compute distance matrix
%D2 = D(eye(size(D))==0);
%D3 = D2(:); % TODO: should be NN distances
% settings for sigma
h.sigma.try = 10.^linspace(-5,10,sigma_try); % quantile(D3,linspace(0,1,sigma_try));

% settings for lambda
h.lambda.try = 10.^linspace(-15,5,lambda_try);

% generate all hyperparameter settings
%hlist = hyper_gen(h); 

% find best hyperparameter settings
% actually just looks up the values from the paper :-)
switch (dataset)
    case 1 % vehicles
        hyp.sigma = 5.270; hyp.lambda = 10^(-3);
    case 2 % heart
        hyp.sigma = 5.906; hyp.lambda = 10^(-1.8);
    case 3 % sonar
        hyp.sigma = 7.084; hyp.lambda = 10^(-2.6);
    case 4 % thyroid
        hyp.sigma = 1.720; hyp.lambda = 10^(-2.6);
    case 5 % ringnorm
        hyp.sigma = 1.778; hyp.lambda = 10^(-3.0);
    case 6 % ionosphere
        hyp.sigma = 4.655; hyp.lambda = 10^(-2.2);
    case 7 % diabetes
        hyp.sigma = 2.955; hyp.lambda = 10^(-1.4);
    case 8 % twonorm
        hyp.sigma = 5.299; hyp.lambda = 10^(-2.2);
    case 9 % banana
        hyp.sigma = 0.645; hyp.lambda = 10^(-2.2);
    case 10 % german
        hyp.sigma = 4.217; hyp.lambda = 10^(-1.4);
    case 11 % splice
        hyp.sigma = 9.481; hyp.lambda = 10^(-2.6);
    case 12 % breast
        hyp.sigma = 4.217; hyp.lambda = 10^(-1.8);
    case 13 % mnist 3vs5
        hyp.sigma = 44.215; hyp.lambda = 10^(-6.0);
    case 14 % mnist 7vs9
        hyp.sigma = 44.215; hyp.lambda = 10^(-3.6);
    case 15 % mnist 5vs8
        hyp.sigma = 44.215; hyp.lambda = 10^(-8.9);
end
MSE = nan(1,1);

% visualize hyperparameter search
vis_par_x = 'sigma';
vis_par_y = 'lambda';

dat.X = X;
dat.y = y;
dat.ids_val = ids_val;
dat.ids_rest = ids_rest;
dat.hyp = hyp;
dat.MSE = MSE;
dat.hlist = [];
dat.vis_par_x = vis_par_x;
dat.vis_par_y = vis_par_y;

end
