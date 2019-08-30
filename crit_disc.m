function disc = crit_disc(K, ind_Q, ind_P)
% computes the discrepancy between Q and P using kernel matrix K
% using equation 5

K_P = K(ind_P,ind_P);

n_Q = length(ind_Q);
n_P = length(ind_P);

D = zeros(size(K,1),1);
D(ind_Q) = D(ind_Q) - 1/n_Q;
D(ind_P) = D(ind_P) + 1/n_P;
D2 = diag(D);

M_K = K_P*D2;

ev = eig(M_K);
disc = max(abs(ev));

end