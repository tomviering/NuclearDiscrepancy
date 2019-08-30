function yhat = krr_test(Ktst, alpha)
% predict the labels of some test objects
% Ktst, kernel between test and train objects
% alpha, parameters of the model

yhat = Ktst*alpha;

end