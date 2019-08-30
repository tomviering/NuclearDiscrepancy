function [res, dat] = exp_reproduce(dataset,alg_list,split_number_train,n_val_trn,mode)
% sets up the settings object for the experiment
%
% dataset:
%
% alg:
% 0 = random
% 1 = MMD (fast, eq after 12)
% 2 = MMD (slow, eq 6)
% 3 = disc
% 4 = ND
%
% split_number_train:
% number in [0,100] that determines the trn / tst split seed
if (nargin < 4)
    n_val_trn = 25;
end
if (nargin < 5)
    mode = 1;
end
% mode = 0: only compute hyperparameters, overwrite old
% mode = 1: perform experiment
% mode = 2: perform experiment using old result data
% mode = 3: load old result data

for alg_i = 1:length(alg_list)
    
    alg = alg_list(alg_i);

    fprintf('\n');
    fprintf('*********************************************\n');
    fprintf('Reproducing experiment\n');
    fprintf('Dataset: %d\n',dataset);
    fprintf('Algorithm: %d\n',alg);
    fprintf('Train / tst split: %d\n',split_number_train);
    fprintf('*********************************************\n');
    fprintf('\n');
    
    settings = struct();

    settings.split_number_train = split_number_train; % seed (0 - 100, used for trn / tst split)
    settings.visualize = 0; % vis hyperopt procedure
    settings.n_queries = 50; % max queries
    
    X = dat_load2(dataset);
    N = size(X,1);

    settings.n_val = N; % number of objects to determine optimal hypothesis class
    
    if (n_val_trn < 0)
        settings.n_val_trn = -n_val_trn; % number of objects to train model with on val data
        settings.n_val_threshold = 50;
    else
        settings.n_val_trn = n_val_trn; % number of objects to train model with on val data
        settings.n_val_threshold = 0;
    end
    settings.val_repeats = 100; % number of trn/test folds to use on val data

    settings.n_test = ceil(0.35*N); % number of objects in test set (maximally)
    settings.n_trn = floor(0.65*N); % number of objects in trn set
    
    settings.lambda_try = 50; % how many lambda's to try on logscale (10^-15, 10^-14, ... 10^5)
    settings.sigma_try = 80; % how many sigma's to try on logscale (10^-5, 10^-4, ... 10^10)

    settings.mode = mode; % what to do
    % mode = 0: only compute hyperparameters, overwrite old
    % mode = 1: perform experiment
    % mode = 2: perform experiment using old result data
    % mode = 3: load old result data
    settings.force_hyperparam_recomp = 0;
    % if 1, recomputes hyperparameters even if they are already computed
    % previously

    % the objective used for active learning
    settings.alg = alg;

    % skip the experiment if it already exists
    settings.skip_if_exists = 1;
    if (mode == 2)
        settings.skip_if_exists = 0;
    end

    % load dataset
    settings.dataset = dataset; % contains instructions to load the dataset
    
    settings.fix_test = 0;
    settings.fix_test_ids = [];
    
    settings.dont_remove_val = 1;

    [res, dat] = exp_run_reproduce(settings);
    
end

end



