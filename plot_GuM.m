function plot_GuM(GuM)
% makes the error decomposition plot
% input: GuM matrix of size (n_trn, n_queries, n_repeats)

% binning of GuM terms: 1, 2-9, 10-49, 50 - rest        
bin_start = [1,2,10,50];
bin_end =   [1,9,49,size(GuM,1)];

queries = [5:5:50]; % where to plot bars

for repeat_i = 1:size(GuM,3)
    
    for q_i = 1:length(queries)

        q_number = queries(q_i);

        for bin_i = 1:(length(bin_start))

            curbin_first = bin_start(bin_i);
            curbin_last = bin_end(bin_i);
            curbin_ind = curbin_first:(curbin_last);
            %[first,last]
            GuM_sums(bin_i,q_i,repeat_i) = sum(GuM(curbin_ind,q_number,repeat_i));

        end

    end
    
end

% average over all repeats
GuM_sums = mean(abs(GuM_sums),3);

mytempbar = bar(GuM_sums','stacked');

% nice colors
set(mytempbar(4),'FaceColor',[237,248,177]/256)
set(mytempbar(3),'FaceColor',[127,205,187]/256)
set(mytempbar(2),'FaceColor',[44,127,184]/256)
set(mytempbar(1),'FaceColor','w')

% set nice legends
B1 = bin_start;
B2 = bin_end;
for bin_i = 1:length(B1)
    if (B1(bin_i) == B2(bin_i))
        leg{bin_i} = sprintf('EV %d',B1(bin_i));
    else
        leg{bin_i} = sprintf('EV %d - %d',B1(bin_i),B2(bin_i));
    end
end
legend(leg)

% set nice Xticks
for q_i = 1:length(queries)
    q_number = queries(q_i)-1;
    xlabels{q_i} = sprintf('%d',q_number);
end
set(gca,'XTickLabel',xlabels)

% set nice axis
tempax = axis;
topax = max(sum(GuM_sums))*1.05; % highest part of plot
axis([0 length(queries)+1 0 topax])

% set axis labels
xlabel('Number of requested labels')
ylabel('Mean contribution to error')