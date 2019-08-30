

for dataset = [1,2,13,14,15] % dataset runs from 1 to 15 (see dat_load2)
    alg_list = [0,1,3,4]; % which active learners to run
    for split_number_train = 0 % random seed to make trn / tst split in [0,100]
        n_val_trn = 50; % actually unused... val data was used to find hyperparameters but is removed from 
        % this version of the code
        
        mode = 1; % do experiment from scratch if not done,
        % if partially done, continue from where we left off,
        % if done already, experiment is skipped

        exp_reproduce(dataset,alg_list,split_number_train,n_val_trn,mode)
        
    end
end