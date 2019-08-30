function D = comp_dist(B,A)
% Computes square Euclidean distance, avoiding large matrices for high 
% dimensional data
% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

    if (nargin < 2)
        A = B;
    end

	ma = size(A,1);
	mb = size(B,1);
	
    D = ones(ma,1)*sum(B'.*B',1); 
    D = D + sum(A.*A,2)*ones(1,mb);
    D = D - 2 .* (+A)*(+B)';
    % Clean result.
    J = find(D<0);
    D(J) = zeros(size(J));
	
end