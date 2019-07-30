clc
close all;
clear all;


    tt=input('Enter 1 to add to existing database, 0 to start new: ');
    if tt==0
        X=[];y=[];
    else
        load('Xydata.mat');
    end

    type = input('Enter: with helmet = 1,  without helmet = 0: ');
    
    
    k=uigetdir;
    k2=strcat(k,'\*.png');
    srcFiles = dir(k2);  % the folder in which images exists
for jj = 1 : length(srcFiles)
        
    fprintf('Processing %d of %d\n',jj,length(srcFiles));
    filename = strcat(strcat(k,'\'),srcFiles(jj).name);
    I = imread(filename);
    
    [r,c,~] = size(I);
    
    r1 = floor(r/4);
    
    I1 = I(1:r,:,:);
%         I1 = I(1:r1,:,:);
    
    figure(1), imshow(I)
      
       pause(.3)
    
    figure(2), imshow(I1)
    
    pause(.5)
    
    I2 = rgb2gray(I1);

    
    % Feature Extraction-------------------
    
     % LBP feature
    
    R=1;
    L = 2*R + 1;
    C = round(L/2);
    
    Ip=padarray(I2,[R,R],'replicate');
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
    

featHOG = HOG(I1);
featHOG = featHOG';

[cA,cH,cV,cD] = dwt2(I1,'haar') ;    % wavelet transform


% figure(3)
% subplot(221),imshow(uint8(cA))
% subplot(222),imshow(uint8(cH))
% subplot(223),imshow(uint8(cV))
% subplot(224),imshow(uint8(cD))
% 
% pause(.6)


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


save Xydatahelmet.mat X y;


