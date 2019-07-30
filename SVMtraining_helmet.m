clc
close all;
clear all;


    fprintf('Loading and Visualizing Data ...\n')
    load ('Xydatahelmet.mat');

    X=double(X);

% Use a linear support vector machine classifier
     
    svmModel = svmtrain(X,y,'Kernel_Function','linear');
   
    
    save Model_SVM_helmet.mat svmModel; 

