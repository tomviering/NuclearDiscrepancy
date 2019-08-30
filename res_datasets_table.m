%% prints dataset information and hyperparameters

% get hyperparameters
for i = 1:15
    % exp_reproduce(dataset,alg_list,split_number_train,n_val_trn,mode)
    [~,dat] = exp_reproduce(i,0,0,0,0);
    
    sigma(i) = dat.hyp.sigma;
    lambda(i) = log10(dat.hyp.lambda);
    
end
%% show table with info
clc;
for i = 1:15
    
    [X,y,dataset_name] = dat_load2(i);
    fprintf('dataset %02d: %20s, dim: %d, N: %d, pos: %d, sigma: %3.3f, lambda %2.1f\n',i,dataset_name,size(X,2),size(X,1),sum(y==1),sigma(i),lambda(i));
    
end
