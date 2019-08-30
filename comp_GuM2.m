function [GuM, GuM2] = comp_GuM2(K, ind_Q, ind_P, K_DP, c_tilde)
% computes the decomposition of the error
K_P = K(ind_P,ind_P);

n_Q = length(ind_Q);
n_P = length(ind_P);

D = zeros(size(K,1),1);
D(ind_Q) = D(ind_Q) - 1/n_Q; 
D(ind_P) = D(ind_P) + 1/n_P;
D2 = diag(D);

M_K = K_P*D2;

[beta_matrix, ev] = eig(M_K'); % beta are columns in beta_matrix
lambda = diag(ev); % compute eigenvalue column vector
lambda = real(lambda);
lambda_abs = abs(lambda); % also removes imaginary values
[lambda_abs_sorted, sort_ind] = sort(lambda_abs,'descend'); % get sort order

n_ev = size(beta_matrix,2);
ubar = nan(n_ev,1); % ubar column vector

for i = 1:n_ev
    
    beta_i = beta_matrix(:,sort_ind(i)); % get coresponding lambda 
    ubar(i) = (c_tilde'*K_DP*beta_i)/(sqrt(beta_i'*K_P*beta_i)); % eq 191
    
end

GuM = lambda_abs_sorted .* (ubar.^2); % GuM column vector
GuM2 = lambda(sort_ind) .* (ubar.^2); % without absolute values of lambda

end