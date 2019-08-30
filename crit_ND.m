function ND = crit_ND(K, ind_Q, ind_P)
% computes Nuclear Discrepancy between Q and P
% using first equation of section 5

K_P = K(ind_P,ind_P);

n_Q = length(ind_Q);
n_P = length(ind_P);

D = zeros(size(K,1),1);
D(ind_Q) = D(ind_Q) - 1/n_Q;
D(ind_P) = D(ind_P) + 1/n_P;
D2 = diag(D);

M_K = K_P*D2;

ev = eig(M_K);
ND = sum(abs(ev));

end