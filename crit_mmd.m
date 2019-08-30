function MMD = crit_mmd(K_original, ind_Q, ind_P)
% fast implementation of MMD [equation below equation 12 in manuscript - in supplement]

K = K_original.^2;

K_Q = K(ind_Q,ind_Q);
K_P = K(ind_P,ind_P);
K_Q_P = K(ind_Q,ind_P);

n_Q = length(ind_Q);
n_P = length(ind_P);

MMD = 1/(n_Q^2)*sum(K_Q(:)) - 2/(n_Q*n_P)*sum(K_Q_P(:)) + 1/(n_P^2)*sum(K_P(:));

end






