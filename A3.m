clc
clear all
close all
load Model_SVM

[filename,filepath]=uigetfile('*.avi;*.jpg;*.mp4;*.png;*.tif','Select video');


% create a video file reader
reader1 =  VideoReader(filename) ;
framerate = reader1.FrameRate;
numFrames = reader1.NumberOfFrames;
w = reader1.Width;
h = reader1.Height;

hfig1=figure(1);
set(hfig1,'units','normal','position',[0.0 0.6 0.3 0.3]);

%hfig2=figure(2);
%set(hfig2,'units','normal','position',[0.5 0.6 0.3 0.3]);

%hfig3=figure(3);
%set(hfig3,'units','normal','position',[0.0 0.1 0.3 0.3]);

hfig3=figure(4);
set(hfig3,'units','normal','position',[0.5 0.1 0.3 0.3]);


for i=2:numFrames
    
    
    % current frame
    f1 = read(reader1,i);
    f1g = rgb2gray(f1);
    %   figure(1),imshow(f1g),title('Current frame')
    
    % previous frame
    f0 = read(reader1,i-1);
    f0g = rgb2gray(f0);
    %   figure(2),imshow(f0g),title('Previous frame')
    
    
    if size(f1,1)*size(f1,2)>500000
        f1 = imresize(f1,.2);
        f1g = imresize(f1g,.2);
        f0g = imresize(f0g,.2);
        w = size(f1g,2);
        h = size(f1g,1);
    end
    
    
    fdiff = abs(f1g-f0g);
    %   figure(1),imshow(fdiff)
    
    [Gmag,Gdir] = imgradient(fdiff);
    
    th = 70;
    
    Ib = zeros(h,w);
    Ib(Gmag>th) = 1;
    
    % morphological operations
    Ib = bwareaopen(Ib,20);
    
    R = 4;
    N = 4;
    SE1 = strel('disk', R, N);
    
    I2 = imdilate(Ib,SE1);
    %         figure(2),imshow(m2)
    
    I2 = imfill(I2,'holes');
    
    pix = round(h*w*.002);
    
    I2 = bwareaopen(I2,pix);
    
    
    % bounding box of objects
    STATS = regionprops(I2,'all');
    if isempty(STATS)
        continue
    end
    
    len = length(STATS);
    
    bboxes = [];
    
    for j = 1:len
        
        bboxes(j,:) = STATS(j).BoundingBox ;
        
    end
    
    f2=f1;
    % Taking each objects
    
    for k=1:len
        
        
        Iobj = imcrop(f1,bboxes(k,:)) ;
        %    figure,imshow(Iobj)
        
        I1 = rgb2gray(Iobj);
        
        
        % Feature Extraction--------------------------------------
        
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
        
        % HOG feature
        
        featHOG = HOG(Iobj);
        featHOG = featHOG';
        
        feature = [featLBP featHOG];
        
        predClass = svmclassify(svmModel,feature)
        
        if predClass ==1
            disp('Bike')
            label = 'Bike';
        else
            disp('Not Bike')
            label = 'Not Bike';
        end
        
        
        f2=insertObjectAnnotation(f2,'rectangle',bboxes(k,:),label);
        
        
        
    end
    
    
    
    %   figure(2),imshow(Gmag)
    %    figure(3),imshow(Ib)
    
    %  obj.videoPlayer1.step(f1);
    %  obj.videoPlayer2.step(fdiff);
    %  obj.videoPlayer3.step(I2);
    
    %  pause(.1)
    
    
    figure(1),imshow(f1),title('Input frame');
   % figure(2),imshow(Gmag),title('Gradient');
   % figure(3),imshow(I2),title('Object detection');
    figure(4),imshow(f2),title('Motorcycle Recognition');
    
end



