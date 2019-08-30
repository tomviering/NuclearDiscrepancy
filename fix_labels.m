function a = fix_labels(a)
% Fixes up the labels of a dataset
% Perform this on the whole dataset (train + test).
% It converts the labels of the dataset to binary labels +1 / -1
% In a consistent way! So no matter the order of the labels, etc.
% It will always result in the same +1 / -1 labeling to be consistent.

ytemp = getnlab(a);
sorted_ytemp = sort(ytemp,1,'descend'); % sort ytemp, so labels always the same
u = unique(sorted_ytemp);
if (size(u,1) > 2)
    error('Multiclass dataset');
end
ytemp = (ytemp == sorted_ytemp(1));
ytemp = (ytemp-0.5)*2;
a = setlabels(a,ytemp);

end

