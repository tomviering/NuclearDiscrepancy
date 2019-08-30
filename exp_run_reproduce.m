function [res,dat] = exp_run_reproduce(settings)
% code to do the actual experiment

% these settings are unused:
% if fix_test = 1, we 'fix' the testset. so it is not random anymore
% fix_test_ids is a vector of ids indicating the test objects in X, y
fix_test = settings.fix_test; % unusued 
fix_test_ids = settings.fix_test_ids; % unusued
fix_test = 0; % unusued

dont_remove_val = settings.dont_remove_val;

split_number_train = settings.split_number_train; % seed (0 - 100, used for trn / tst split)
visualize = settings.visualize; % vis hyperopt procedure
n_queries = settings.n_queries; % max queries

% these settings are unused:
n_val = settings.n_val; % number of objects to determine optimal hypothesis class % unusued
n_val_trn = settings.n_val_trn; % number of objects to train model with on val data % unusued
val_repeats = settings.val_repeats; % number of trn/test folds to use on val data % unusued
n_val_threshold = settings.n_val_threshold; % threshold for MSE results % unusued
str_preprocess_settings = 'paper';

n_test_max = settings.n_test; % number of objects in test set (maximally) 
lambda_try = settings.lambda_try; % how many lambda's to try on logscale (10^-15, 10^-14, ... 10^5) % unusued
sigma_try = settings.sigma_try; % how many sigma's to try (quantiles of distances, 0.1, 0.2, ... 0.9) % unusued

n_trn = settings.n_trn; % number of objects in trn set

mode = settings.mode; % what to do
% mode = 0: only compute hyperparameters, overwrite old
% mode = 1: perform experiment
% mode = 2: perform experiment using old result data
force_hyperparam_recomp = settings.force_hyperparam_recomp;
% if 1, recomputes hyperparameters even if they are already computed
% previously

% the objective used for active learning
alg = settings.alg;
% 0 = random
% 1 = MMD (fast, equation directly after eq 12)
%   = {MMD_comp(Q,Q) - 2MMD_comp(P,Q) + MMD_comp(P,P)}
% 2 = MMD (slow, eq 7)
% 3 = disc
% 4 = ND

% load dataset
dataset = settings.dataset; % contains instructions to load the dataset

% skip if results already exist
skip_if_exists = settings.skip_if_exists;

% result file
filename_result = sprintf('results/R_%d_%d_%d_%s.mat',dataset,alg+1,split_number_train+1,str_preprocess_settings);
filename_settings = sprintf('settings/R_%d_%d_%d_%s.mat',dataset,alg+1,split_number_train+1,str_preprocess_settings);

% temporary file (can continue computation even in case of crash or abort)
fn_temp = sprintf('results/R_tmp_%d_%d_%d_%d_%s.mat',dataset,alg+1,split_number_train+1,settings.n_trn,str_preprocess_settings);

[X,y,dataset_name] = dat_load2(dataset);

filename_preprocessed = sprintf('preprocessed/R_%s_%s.mat',dataset_name,str_preprocess_settings);
fprintf('Preprocess file %s\n',filename_preprocessed);

preprocessed_exist = exist(filename_preprocessed,'file');

% do preprocessing?
if ~preprocessed_exist || force_hyperparam_recomp || mode==0
    dat = dat_preprocess(X,y,sigma_try,lambda_try,n_val,n_val_trn,val_repeats,n_val_threshold,dataset); % uses rng(1) to get splits and do hyp opt
    save(filename_preprocessed, '-struct', 'dat'); % save processed dataset
    fprintf('Preprocessed data\n');
else
    fprintf('Loaded preprocessed data\n');
    dat = load(filename_preprocessed); % load processed dataset
end

if (visualize == 1) % visualize hyperpar search % unused
    title_opthyp = sprintf('%s (N1: %d, N2: %d, R: %d)',dataset_name,n_val,n_val_trn,val_repeats);
    plot_opthyp(dat.MSE, dat.hlist, dat.hyp, dat.vis_par_x, dat.vis_par_y, title_opthyp);
end

fprintf('Using hyperparameter settings:\n');
dat.hyp

results_exist = exist(filename_result,'file');
if (skip_if_exists && results_exist)
    fprintf('This results file already exists! %s\nSkipping experiment...\n',filename_result);
    res = [];
    return;
end

if (mode == 0)
    res = struct();
    return; % we are done, we only were retrieving dataset info
end

% get the train and test splits
X = dat.X;
y = dat.y;
ids_rest = dat.ids_rest;
hyp = dat.hyp;

if (fix_test == 1)||(dont_remove_val == 1)
    % use all objects instead!
    ids_rest = 1:size(X,1);
end

% from now on we only use the dataset 'rest'
% since we used the val data to choose hyperparam
% (actually, for the paper version the val data is not removed..)
X_rest = X(ids_rest,:);
y_rest = y(ids_rest);
n_rest = length(y_rest);

% 0 was used for subsampling
% 1 was used to generate val split
rng(split_number_train+2);
% so we want to start at 2

% generate 'trn' and tst split
ids = randperm(n_rest);

% maximum test id
test_maxid = min(length(ids),n_trn+n_test_max);

if (fix_test == 1) % not used anymore
    ids_tst = fix_test_ids;
    n_test = length(ids_tst);
    
    ids_all = 1:n_rest;
    ids_all(ids_test) = []; % remove test ids
    
    n_tmp = length(ids_all);
    p_tmp = randperm(n_tmp);
    ids_all = ids_all(p_tmp); % shuffle remaining ids
    
    if (n_trn <= length(ids_all)) 
        ids_trn = ids_all(1:n_trn);
    else
        ids_trn = ids_all;
        warning('the training set is so large, we used up all objects...');
    end
else
    ids_tst = ids(n_trn+1:test_maxid);
    n_test = length(ids_tst);
    ids_trn = ids(1:n_trn);
end

% trainset
% this dataset is the data that the AL can 'see'
% consists of unlabeled and labeled part (this is P)
X_trn = X_rest(ids_trn,:);
y_trn = y_rest(ids_trn);
K_trn = comp_kernel(hyp.sigma, X_trn); 
n_trn = length(y_trn);
ids_exp = 1:n_trn; % ids used during active learning

% testset
% the active learner cannot 'see' this data
X_tst = X_rest(ids_tst,:);
y_tst = y_rest(ids_tst);
K_tst_trn = comp_kernel(hyp.sigma, X_tst, X_trn);

% fit regression model to [trn,tst] set (call that set T)
% to make the problem realizeable (no model misspecification)
fprintf('Fitting model to complete dataset...\n');
ids_T = [ids_trn, ids_tst];
X_T = X_rest(ids_T,:);
y_T = y_rest(ids_T,:);

K_T = comp_kernel(hyp.sigma, X_T);
alpha_oracle = krr_train(K_T, y_T, hyp.lambda);
y_T_rea = krr_test(K_T, alpha_oracle); % realizeable labels
y_trn_rea = y_T_rea(1:n_trn);
y_tst_rea = y_T_rea(n_trn+1:end);
clear K_T; % we only use this matrix once

fprintf('Computed realizeable targets.\n');

% for GuM computation we require the kernel K_DP
K_T_trn = comp_kernel(hyp.sigma, X_T, X_trn);
GuM = nan(n_trn,n_queries);

% start the experiment
mask_labeled = zeros(n_trn,1); % initially all unlabeled

% MSE init
MSE_tst = nan(n_queries,1);
MSE_tst_rea = nan(n_queries,1);
MSE_trn = nan(n_queries,1);
MSE_trn_rea = nan(n_queries,1);

objective_hist = nan(n_trn,n_queries);

% Set the AL algorithm
switch (alg)
    case 0
        func = @(K,ids_Q,ids_P) rand(1,1);
    case 1 
        func = @(K,ids_Q,ids_P) crit_mmd(K,ids_Q,ids_P); % fast
    case 2 
        func = @(K,ids_Q,ids_P) crit_mmd2(K,ids_Q,ids_P); % slow
    case 3 
        func = @(K,ids_Q,ids_P) crit_disc(K,ids_Q,ids_P);
    case 4 
        func = @(K,ids_Q,ids_P) crit_ND(K,ids_Q,ids_P);
    otherwise
        error('unknown active learner');
end

if (mode == 2)||(mode == 3)
    if (~exist(filename_result,'file'))
        error('could not find result file');
    end
    fprintf('Loading existing result file...\n');
    res_hist = load(filename_result);
end

if (mode == 3)
    res = res_hist;
    return;
end


i_q_start = 1;
fprintf('Checking if temp data exists at %s\n',fn_temp);
if exist(fn_temp) == 2
    load(fn_temp);
    i_q_start = i_q+1;
    fprintf('Yes! Loaded intermediate results... :)\n');
end

% start the AL experiment
time_start = tic;
for i_q = i_q_start:n_queries
    
    time_elapsed = round(toc(time_start));
    time_per_query = round(time_elapsed/(i_q-1));
    
    fprintf('Query %2d of %2d (T Elapsed: %d, T/Q: %d)...\n',i_q,n_queries,time_elapsed,time_per_query);
    ids_lab_old = ids_exp(mask_labeled == 1);
    ids_unl_old = ids_exp(mask_labeled == 0);
    
    objective = nan(length(ids_unl_old),1);
    
    if (mode == 2)
       objective = res_hist.objective_hist(1:length(objective),i_q);
    else
         % try each unlabeled object
        for i_unl = 1:length(ids_unl_old)

            id = ids_unl_old(i_unl); % id of current object
            mask_labeled_new = mask_labeled;
            mask_labeled_new(id) = 1; % add it to labeled set

            % get new sets (temporarily)
            ids_lab_new = ids_exp(mask_labeled_new == 1);
            ids_unl_new = ids_exp(mask_labeled_new == 0);

            ids_Q_new = ids_lab_new;
            ids_P_new = ids_exp; % all of trnset

            % compute objective
            objective(i_unl) = func(K_trn, ids_Q_new, ids_P_new); 
        end
    end
    
    % store objectives because they are expensive to compute
    objective_hist(1:length(objective),i_q) = objective;
    
    % compute best object
    [best_obj, i_best] = min(objective);
    id_best = ids_unl_old(i_best); 
    
    % add it to the definitive labeled set
    mask_labeled(id_best) = 1;

    % get new ids (definitive)
    ids_lab = ids_exp(mask_labeled == 1);
    ids_unl = ids_exp(mask_labeled == 0);
    
    % get kernel matrices
    K_lab = K_trn(ids_lab,ids_lab);
    K_trn_lab = K_trn(:,ids_lab);
    K_tst_lab = K_tst_trn(:,ids_lab);
    
    % evaluate agnostic case
    alpha = krr_train(K_lab,y_trn(ids_lab),hyp.lambda);
    yhat_tst = krr_test(K_tst_lab,alpha);
    yhat_trn = krr_test(K_trn_lab,alpha);
    
    MSE_tst(i_q) = mean((yhat_tst - y_tst).^2);
    MSE_trn(i_q) = mean((yhat_trn - y_trn).^2);
    
    % evaluate realizeable case
    alpha_rea = krr_train(K_lab,y_trn_rea(ids_lab),hyp.lambda);
    yhat_tst_rea = krr_test(K_tst_lab,alpha_rea);
    yhat_trn_rea = krr_test(K_trn_lab,alpha_rea);
    
    MSE_tst_rea(i_q) = mean((yhat_tst_rea - y_tst_rea).^2);
    MSE_trn_rea(i_q) = mean((yhat_trn_rea - y_trn_rea).^2);
    
    
    
    % compute error decomposition GuM (see section 6.3)
    alpha_h = alpha_rea;
    
    % form new sets P, Q
    ids_Q = ids_lab;
    ids_P = ids_exp; % all of trnset
    
    errors = (yhat_trn_rea - y_trn_rea).^2;
    MSE_P_rea = mean(errors(ids_P));
    MSE_Q_rea = mean(errors(ids_Q));
    
    % compute ctilde
    c_tilde = nan(n_rest,1); % work with respect to rest set
    c_tilde(ids_T) = alpha_oracle; % ids_T are wrt rest
    % ids_lab are wrt ids_trn
    ids_lab_wrt_rest = (ids_trn(ids_lab)); % now lab wrt rest
    % subtract current hypothesis
    % alpha_h is indexed by ids_lab_wrt_rest wrt rest
    c_tilde(ids_lab_wrt_rest) = c_tilde(ids_lab_wrt_rest) - alpha_h(:);
    % c_tilde is wrt the rest set, but this set is very big
    c_tilde2 = c_tilde(ids_T); % get c_tilde2 wrt set T
    
    % compute kernel matrix K_DP
    K_TP = K_T_trn(:,ids_P); 
    
    % c_tilde2 matches the first set of K_TP
    % ids_P match the second set of K_TP
    
    % compute GuM
    % GuM(:,i_q) = comp_GuM(K_trn, ids_Q, ids_P, K_TP, c_tilde2); % this
    % code had a missing transpose
    [GuM(:,i_q),GuM_check] = comp_GuM2(K_trn, ids_Q, ids_P, K_TP, c_tilde2);
    
    umu1 = MSE_P_rea - MSE_Q_rea;
    umu2 = sum(GuM_check);
    comp_diff('umu vs GuM', umu1, umu2)
    % if there are many stars (*) this indicates a problem
    
    tic
    save(fn_temp);
    save_time = toc;
    
    %fprintf('Saved intermediate result in %d seconds...\n',floor(save_time));
    
end
exp_time = toc(time_start);

res.objective_hist = objective_hist;
res.MSE_tst = MSE_tst;
res.MSE_trn = MSE_trn;
res.MSE_tst_rea = MSE_tst_rea;
res.MSE_trn_rea = MSE_trn_rea;
res.GuM = GuM;
res.exp_time = exp_time;

fprintf('Saving to file %s...\n',filename_result);

if (mode ~= 2)
    save(filename_result,'-struct','res');
    save(filename_settings,'-struct','settings');
    
    fprintf('Saved results and settings to file.\n');
    
else
    
    ignore_fields = {'objective_hist','exp_time'};
    res_new = rmfield(res,ignore_fields);
    res_old = rmfield(res_hist,ignore_fields);
    
    if (isequal(res_new,res_old) == false)
        warning('Results are not the same');
    else
        fprintf('Results are the same\n');
    end
end

end
