function A = rescale(B)
% scale something to [0,1]

C = B - min(B);
D = C./max(C);
A = D;

end