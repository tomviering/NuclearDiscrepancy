%% makes the table with all the results and bold numbers
clc

clear all;

% 1 = agnostic
% 2 = realizeable
mycontext = 2;

% 
%% load results for a given dataset

for dataset = 1:2
clearvars -except Tkeep AULC_r2 dataset txt_dataset_total AULC2 mycontext
[X,~,txt_dataset] = dat_load2(dataset);
Nval = size(X,1);
Ngum = floor(0.65*Nval); 

% 0 = randomexp_run      (1)
% 1 = MMD (fast, eq 37)  (2)
% 2 = MMD (slow, eq 16)  (3)
% 3 = disc               (4)
% 4 = ND                 (5)

% final_names = {'Disc (worst case)','Nuclear Disc (optimistic case)','MMD (pessimistic case)','Random'};

alg_names = {'Random','MMD (pessimistic case)','MMD slow','Disc (worst case)','Nuclear Disc (optimistic case)'};
%[~,~,txt_dataset] = dat_load(dataset);
txt_dataset_total{dataset} = txt_dataset;

missing = 0;

missing_splits = [];

queries = 1:50;
GuM_num = 1:Ngum;

splits_todo = 1:100;
%ids_alg = [1,2,4,5]; %[1]% ,2,4,5];
ids_alg = [4,5,2,1]; % in the order we want them to appear in the plot

folder = 'results'; % no leading slash
res_str_after = sprintf('_paper.mat');

missing_list = {};

for alg_num_i = 1:length(ids_alg)
    for split_number_train = splits_todo
    
        alg_num = ids_alg(alg_num_i);
        
        results_name = sprintf('R_%d_%d_%d',dataset,alg_num,split_number_train);
        results_filename = sprintf('%s/%s%s',folder,results_name,res_str_after);
        
        if (exist(results_filename,'file') == 0)
            fprintf('Result file %s does not exist. Skipping.\n',results_filename);
            missing = missing+1;
            missing_list{end+1} = results_filename;
            missing_splits(end+1) = split_number_train;
            continue;
        end
        
        res = load(results_filename);
        MSE_tst(queries,alg_num_i,split_number_train) = res.MSE_tst;
        MSE_trn(queries,alg_num_i,split_number_train) = res.MSE_trn;
        MSE_tst_rea(queries,alg_num_i,split_number_train) = res.MSE_tst_rea;
        MSE_trn_rea(queries,alg_num_i,split_number_train) = res.MSE_trn_rea;
        GuM(queries,:,alg_num_i,split_number_train) = res.GuM';
        
    end
end

fprintf('Missing %d files.\n',missing);

%% remove missing splits
for i = 1:length(missing_splits)
    split_to_remove = missing_splits(i);
    id_to_remove = find(split_to_remove == splits_todo);
    splits_todo(id_to_remove) = [];
end

ids_splits2 = splits_todo;
alg_names2 = {};
for i = 1:length(ids_alg)
    alg_names2{i} = alg_names{ids_alg(i)};
end
ids_alg2 = 1:length(ids_alg);

%% get all curves
clear trn tst;
tst.agn = res_comp_curve(MSE_tst, ids_alg2, ids_splits2);
tst.rea = res_comp_curve(MSE_tst_rea, ids_alg2, ids_splits2);
trn.agn = res_comp_curve(MSE_trn, ids_alg2, ids_splits2);
trn.rea = res_comp_curve(MSE_trn_rea, ids_alg2, ids_splits2);

cur_context = 1;
num_contexts = 2; % only do testset

% context, algorithm, repeats
AULC = nan(length(num_contexts),length(ids_alg),length(ids_splits2));

for realizeable = 0:1 % realizeable
for testset = 0:1 % testset

object = [];
if (testset == 1)
    txt_set = 'test set';
    txt_set_short = 'TST';
    object = tst;
else
    txt_set = 'train set';
    txt_set_short = 'TRN';
    object = trn;
    continue; % skip the ones with the training set... not interesting
end
if (realizeable == 1)
    txt_setting = 'realizeable';
    txt_setting_short = 'REA';
    object = object.rea;
else
    txt_setting = 'agnostic';
    txt_setting_short = 'AGN';
    object = object.agn;
end

AULC(cur_context,:,:) = object.AULC;

context = [txt_setting_short, ' ', txt_set_short];
context_list{cur_context} = context;
cur_context = cur_context+1;

end
end

%% reorder results and put into main matrix

reorder = [4,1,3,2];
clear AULC_r;
AULC_r = AULC(:,reorder,:);
AULC2(:,:,:,dataset) = AULC_r;
end

%% put all results together in a table
addpath('restools-master/matlab');

dim1 = context_list;
alg_names3 = {'Discrepancy','Nuclear Discrepancy','MMD','Random'};
alg_names4{1} = alg_names3{reorder(1)};
alg_names4{2} = alg_names3{reorder(2)};
alg_names4{3} = alg_names3{reorder(3)};
alg_names4{4} = alg_names3{reorder(4)};

dim2 = alg_names4;
dim3 = ids_splits2;

for i = 1:length(txt_dataset_total)
    if (length(txt_dataset_total{i}) == 0)
        txt_dataset_total{i} = 'no dataset';
    end
end

dim4 = txt_dataset_total;

R = results(squeeze(AULC2(mycontext,:,:,:)),dim2,dim3,dim4);
R = setdimname(R,'algorithms','split','dataset');
% Set the results name:
R = setname(R,['AULC ' context_list{mycontext}]);

fprintf(['context: ' context_list{mycontext} '\n'])

%% make dataset table with result

T = average(R,2,'min1','dep'); % average over splits
T = permute(T,[1,3,2]);
txt = evalc('show(T'',''html'')');
web(['text://<html>',txt,'</html>']);


