clc
close all;
clear all;


    tt=input('Enter 1 to add to existing database, 0 to start new: ');
    if tt==0
        X=[];y=[];
    else
        load('Xydata.mat');
    end

    type = input('Enter: Bike = 1, Not bike = 0: ');
    
    
    k=uigetdir;
    k2=strcat(k,'\*.jpg');
    srcFiles = dir(k2);  % the folder in which images exists
for jj = 1 : length(srcFiles)
        
    fprintf('Processing %d of %d\n',jj,length(srcFiles));
    filename = strcat(strcat(k,'\'),srcFiles(jj).name);
    I = imread(filename);
    
    I1 = rgb2gray(I);
    
    % Feature Extraction-------------------
    
     % LBP feature
    
    R=1;
    L = 2*R + 1;
    C = round(L/2);
    
    Ip=padarray(I1,[R,R],'replicate');
    [rk,ck]=size(Ip);
    
  LBP1 = zeros(rk,ck);
  
for ii = R+1:rk-R
    for j = R+1:ck-R
        A = double(Ip(ii-R:ii+R, j-R:j+R));
        A = A-A(C,C);
        A(A>=0) = 1;
        A(A<0)=0;
      
        LBP1(ii,j) = A(1,1)*1 + A(1,2)*2 + A(1,3)*4 + A(2,1)*8 + A(2,3)*16 + A(3,1)*32 + A(3,2)*64 + A(3,3)*128;
    
    end
end

LBP=LBP1(R+1:rk-R,R+1:ck-R);
% figure,imshow(uint8(LBP)),title('LBP feature')

featLBP = imhist(uint8(LBP))';
    

featHOG = HOG(I);
featHOG = featHOG';

% Final Feature

feature = [featLBP featHOG];


    if type==1
        X=[X; feature];
        y=[y;1];
    elseif type==0
        X=[X; feature];
        y=[y;0];
    end

end

save Xydata.mat X y;

