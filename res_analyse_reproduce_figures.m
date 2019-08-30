%% generates all figures of the paper and puts them
% in the folder 'repr'
clc

clear all;

addpath('export_fig');

% 
%% load results for a given dataset

for dataset = [13:15]
clearvars -except Tkeep AULC_r2 dataset txt_dataset_total AULC2 
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
res_str_after = sprintf('_paper.mat',Nval);

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

clear trn tst;
tst.agn = res_comp_curve(MSE_tst, ids_alg2, ids_splits2);
tst.rea = res_comp_curve(MSE_tst_rea, ids_alg2, ids_splits2);
trn.agn = res_comp_curve(MSE_trn, ids_alg2, ids_splits2);
trn.rea = res_comp_curve(MSE_trn_rea, ids_alg2, ids_splits2);

%temp = trn.rea.MSE_mean;
%temp2 = squeeze(sum(GuM2,2));

GuM2 = squeeze(mean(GuM(:,:,ids_alg2,ids_splits2),4));

%% do nice analysis

red = [222/256, 23/256,31/256];
blue = [0, 97/256, 173/256];
green = [0, 191/256, 36/256];
%styles.line{curind},'LineWidth',styles.linethick{curind},'Color',styles.color{curind}
c{1} = red;     % Disc
c{2} = green;   % ND
c{3} = blue;    % MMD
c{4} = [0,0,0]; % Rand
lt{1} = 2;
lt{2} = 2;
lt{3} = 2;
lt{4} = 1;
line{1} = '--';
line{2} = ':'; 
line{3} = '-'; 
line{4} = ':'; 

close all
first = 1;
cur_context = 1;
num_contexts = 2;

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

figure;
Queries = repmat(queries,length(ids_alg),1)';
hold on

randmean = object.MSE_mean(:,4);
errorbar_ind = 10:10:50;

for i = 1:4
    h(i) = plot(Queries(:,i),object.MSE_mean(:,i)-randmean,line{i},'Color',c{i},'LineWidth',lt{i});
    errorbar(Queries(errorbar_ind,i)+(i-4)/4,object.MSE_mean(errorbar_ind,i)-randmean(errorbar_ind,:),object.MSE_std(errorbar_ind,i)/sqrt(length(splits_todo))*1.96,'.','Color',c{i},'LineWidth',1);
end

%plot(Queries,object.MSE_mean)

title(sprintf('%s %s %s',txt_dataset,txt_setting,txt_set));
legend(h,alg_names2,'Location','SouthEast')

AULC(cur_context,:,:) = object.AULC;

context = [txt_setting_short, ' ', txt_set_short];
context_list{cur_context} = context;
cur_context = cur_context+1;

xlabel('Batch size n');
ylabel('MSE difference on testset');

tight = 1;
if (tight == 1)
    ax = gca;
    outerpos = get(ax,'OuterPosition');
    ti = get(ax,'TightInset'); 
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    set(ax,'Position',[left bottom ax_width ax_height]);
end
set(gcf,'color','w');
title('');

export_fig(sprintf('repr/lc_%s_%d_legend1',txt_setting,dataset),'-pdf','-transparent')

legend('hide')

export_fig(sprintf('repr/lc_%s_%d_legend0',txt_setting,dataset),'-pdf','-transparent')

end
end
%%
% i = active learner, do random
for i = 4%1:size(GuM2,3)
    GuM_temp = GuM2(:,:,i);
    figure
    plot_GuM(GuM_temp');
    title(sprintf('%s %s',txt_dataset,alg_names2{i}));
    
    set(gca,'XTickLabel',{'5','10','15','20','25','30','35','40','45','50'}');
    xlabel('Batch size n')
    
    set(gcf,'color','w');
    title('');
    
    
    export_fig(sprintf('repr/gum_random_%d_legend1.pdf',dataset),'-pdf','-transparent', gcf)

    legend('hide');

    export_fig(sprintf('repr/gum_random_%d_legend0.pdf',dataset),'-pdf','-transparent', gcf)

end
%%

reorder = [4,1,3,2];
clear AULC_r;
AULC_r = AULC(:,reorder,:);
AULC2(:,:,:,dataset) = AULC_r;
end
