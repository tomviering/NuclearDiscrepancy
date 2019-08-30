function [X,y,dataset_name] = dat_load2(dat_id)
% loads the dataset 
% dataset 01:             vehicles, dim: 18, N: 435, pos: 218
% dataset 02:                heart, dim: 13, N: 297, pos: 137
% dataset 03:                sonar, dim: 60, N: 208, pos: 97
% dataset 04:              thyroid, dim: 5, N: 215, pos: 65
% dataset 05:             ringnorm, dim: 20, N: 1000, pos: 510
% dataset 06:           ionosphere, dim: 34, N: 351, pos: 126
% dataset 07:             diabetes, dim: 8, N: 768, pos: 500
% dataset 08:              twonorm, dim: 20, N: 1000, pos: 510
% dataset 09:               banana, dim: 2, N: 1000, pos: 440
% dataset 10:               german, dim: 20, N: 1000, pos: 300
% dataset 11:               splice, dim: 60, N: 1000, pos: 433
% dataset 12:               breast, dim: 9, N: 683, pos: 239
% dataset 13:            mnist3vs5, dim: 784, N: 1000, pos: 484
% dataset 14:            mnist7vs9, dim: 784, N: 1000, pos: 510
% dataset 15:            mnist5vs8, dim: 784, N: 1000, pos: 535

addpath('data/UCI/');

switch (dat_id)
    
    case 0
        
        print_table()
        return
    
    case 1 % vehicles
        addpath('data/UCI/vehicle');
        addpath('data/UCI/prtools');
        addpath('data/UCI/');
        
        a = dat_vehicles();
        [X,y] = preprocess_prtools_data(a);
        
        dataset_name = 'vehicles';
    case 2 % heart
        addpath('data/UCI/prtools');
        addpath('data/UCI/');
        
        a = heart();
        [X,y] = preprocess_prtools_data(a);
        dataset_name = 'heart';
        
        % PrTools version contained some missing values...
        
        %temp = load('benchmarks.mat');
        %X = temp.heart.x;
        %y = temp.heart.t;
        %dataset_name = 'heart';
        
    case 3 % sonar
        addpath('data/UCI/prtools');
        addpath('data/UCI/');
        
        a = sonar();
        [X,y] = preprocess_prtools_data(a);
        dataset_name = 'sonar';
        
    case 4 % thyroid
        
        temp = load('benchmarks.mat');
        X = temp.thyroid.x;
        y = temp.thyroid.t;
        dataset_name = 'thyroid';
        
    case 5 % ringnorm
        
        temp = load('benchmarks.mat');
        X = temp.ringnorm.x;
        y = temp.ringnorm.t;
        dataset_name = 'ringnorm';
        
    case 6 % ionosphere
        
        addpath('data/UCI/prtools');
        addpath('data/UCI/');
        
        a = ionosphere();
        [X,y] = preprocess_prtools_data(a);
        dataset_name = 'ionosphere';
        
    case 7 % diabetes
        
        addpath('data/UCI/prtools');
        addpath('data/UCI/');
        
        a = diabetes();
        [X,y] = preprocess_prtools_data(a);
        dataset_name = 'diabetes';
        
    case 8 % twonorm
        
        temp = load('benchmarks.mat');
        X = temp.twonorm.x;
        y = temp.twonorm.t;
        dataset_name = 'twonorm';
        
    case 9 % banana
        
        temp = load('benchmarks.mat');
        X = temp.banana.x;
        y = temp.banana.t;
        dataset_name = 'banana';
        
    case 10 % german
        
        temp = load('benchmarks.mat');
        X = temp.german.x;
        y = temp.german.t;
        dataset_name = 'german';
        
    case 11 % splice
        
        temp = load('benchmarks.mat');
        X = temp.splice.x;
        y = temp.splice.t;
        dataset_name = 'splice';
        
    case 12 % breast
       
        addpath('data/UCI/prtools');
        addpath('data/UCI/');
        
        a = breast();
        [X,y] = preprocess_prtools_data(a);
        dataset_name = 'breast';
        
    case 13
        load('data/Orig-MNIST-dataset.mat');
        X = [fea(gnd==3,:); fea(gnd==5,:)];
        Y = [gnd(gnd ==3); gnd(gnd==5)];
        Y = Y-4;
        y = Y;
        
        dataset_name = 'mnist3vs5';

    case 14
        load('data/Orig-MNIST-dataset.mat');
        X = [fea(gnd==7,:); fea(gnd==9,:)];
        Y = [gnd(gnd ==7); gnd(gnd==9)];
        Y = Y-8;
        y = Y;
        
        dataset_name = 'mnist7vs9';

    case 15
        load('data/Orig-MNIST-dataset.mat');
        X = [fea(gnd==5,:); fea(gnd==8,:)];
        Y = [gnd(gnd ==5); gnd(gnd==8)];
        Y = (Y-6.5)/1.5;
        y = Y;
        
        dataset_name = 'mnist5vs8';
        
        
    otherwise
        error('unknown dataset');
end

% if dataset is too large, subsample
if size(X,1) > 1000
    rng(0);
    R = randperm(size(X,1));
    X = X(R,:);
    y = y(R,:);
    X = X(1:1000,:);
    y = y(1:1000);
end

addpath('data/UCI/vehicle');
addpath('data/UCI/prtools');
addpath('data/UCI/');

rmpath('data/UCI/vehicle');
rmpath('data/UCI/prtools');
rmpath('data/UCI/');

% check for errors one last time
temp1 = isnan(X);
temp2 = isinf(X);
temp3 = isnan(y);
temp4 = isinf(y);
problems = sum([temp1(:);temp2(:);temp3(:);temp4(:)]);
if (problems > 0)
    error(sprintf('The dataset %d contained missing values!',dat_id));
end

end

function print_table()

for i = 1:15
    [X,y,dataset_name] = dat_load2(i);
    fprintf('dataset %02d: %20s, dim: %d, N: %d, pos: %d\n',i,dataset_name,size(X,2),size(X,1),sum(y==1));
end

end

function [X,y] = preprocess_prtools_data(a)
    a = fix_labels(a);
    a = misval(a,'remove'); % remove objects with missing values
    X = +a;
    y = getlab(a);
end



