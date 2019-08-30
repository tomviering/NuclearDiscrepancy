function processed = res_comp_curve(res_matrix, ids_alg, ids_splits)
% computes the learning curve and some other stuff
% queries, algorithm, splits

res_matrix2 = res_matrix(:,ids_alg,ids_splits);
res_mean = mean(res_matrix2,3);
res_std = std(res_matrix2,[],3);

res_area = sum(res_matrix2,1); % sum over queries
res_area_mean = mean(res_area,3); % mean area
res_area_std  = std(res_area,[],3); % std area

processed.MSE_mean = res_mean;
processed.MSE_std = res_std;
processed.AULC = (res_area);
% res area: 1, algorithm, splits
processed.AULC_mean = res_area_mean;
processed.AULC_std = res_area_std;

end