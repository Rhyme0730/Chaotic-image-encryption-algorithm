%%================================================================================
%This demo is to demonstrate the image encryption using the reference in
%         [1]. Hua, Zhongyun, et al. "2D Sine Logistic modulation map for image encryption." 
%              Information Sciences 297 (2015): 80-94.
%All copyrights are reserved by Zhongyun Hua. E-mial:huazyum@gmail.com
%All following source code is free to distribute, to use, and to modify
%    for research and study purposes, but absolutely NOT for commercial uses.
%If you use any of the following code in your academic publication(s), 
%    please cite the corresponding paper. 
%If you have any questions, please email me and I will try to response you ASAP.
%It worthwhile to note that all following source code is written under MATLAB R2010a
%    and that files may call built-in functions from specific toolbox(es).
%%================================================================================
%
%%================================================================================
% This demo is to demonstrate the 1. Load plaintext images; 2. encryption; 
% 3. decryption; 4. Analaysis. Inluding 4.1 Histogram; 
% 4.2 the Local Shannon entropy test; 4.3 the NPCR and UACI test; 
% 4.4 Key Sensitivity
%%================================================================================
%%
clear all
close all
clc
%% 1. Load plaintext images
% Image 1
%P = imread('cameraman.tif');
P = imread('peppers.tif');
% P=[1 2 3 4;
%    5 6 7 8;
%    9 10 11 12;
%    13 14 15 16];
%%=========================================================================

%% 2. Encryption
[C,K] = ImageCipher(P,'encryption');
%%=========================================================================

%% 3. Decryption
D = ImageCipher(C,'decryption',K);
%%=========================================================================

%% 4. Analaysis
% 4.1 Histogram
figure,subplot(221),imshow(P,[]),subplot(222),imshow(C,[])
subplot(223),imhist(P),subplot(224),imhist(C)
%%=========================================================================

% 4.2 the Local Shannon entropy test
%LSE = LocalEntropy(C);
%%=========================================================================

% 4.3 the NPCR and UACI test
% change one bit of a randomly selected pixel 
% to generate a new plaintext image P2
[row, column] = size(P);
r = randi(row,1);
c = randi(column,1);
P2 = P;
if P2(r,c) == 0
    P2(r,c) = P2(r,c)+1;
else
    P2(r,c) = P2(r,c) -1;
end

% encrypte P2 with the same security key K
C2 = ImageCipher(P2,'encryption',K);

% compute the NPCR value of C and C2;
D = zeros(row,column);
for i = 1:row
    for j = 1:column
        if C2(i,j) ~= C(i,j)
            D(i,j) = 1;
        end
    end
end
NPCR = sum(D(:))/(row*column)*100;

% compute the UACI value of C and C2;
C = double(C);
C2 = double(C2);
A = zeros(row,column);
for i = 1:row
    for j = 1:column
        A(i,j)=abs(C(i,j)-C2(i,j));
    end
end
UACI = sum(A(:))/(255*row*column)*100;
%%=========================================================================

% 4.4 Key Sensitivity
% Load plaintext images
% P = imread('cameraman.tif');
 P = imread('peppers.tif');
% P=[1 2 3 4;
%    5 6 7 8;
%    9 10 11 12;
%    13 14 15 16];

% Generate three similar keys
K = round(rand(1,256));
K2 = K;
K2(200) = 1-K(200);

K3 = K;
K3(240) = 1-K(240);

% Encryption Sensitivity
C = ImageCipher(P,'encryption',K);
C2 = ImageCipher(P,'encryption',K2);


% Decryption Sensitivity
D = ImageCipher(C,'decryption',K);
D2 = ImageCipher(C,'decryption',K2);
D3 = ImageCipher(C,'decryption',K3);

% LocalShannonEntropy
M1=LocalShannonEntropy(P);
M2=LocalShannonEntropy(C);

figure,
subplot(241),imshow(P,[]),title('P'),subplot(242),imshow(C,[]),title('C_1'),
subplot(243),imshow(C2,[]),title('C_2'),subplot(244),imshow(imabsdiff(C,C2),[]),title('|C_1-C_2|'),
subplot(245),imshow(D,[]),title('D_1'),subplot(246),imshow(D2,[]),title('D_2'),
subplot(247),imshow(D3,[]),title('D_3'),subplot(248),imshow(imabsdiff(D2,D3),[]),title('|D_2-D_3|')

%% 裁剪分析
% C5=C;
% %  C5(1:90,1:90)=0;
% D5 = ImageCipher(C5,'decryption',K);
% 
% figure,
% imshow(D5,[])

%% 噪声分析
%salt

% C5=C;
% t1=imnoise(C5,'salt & pepper',0.02);
% 
% figure,
% imshow(t1,[])
% 
% D5 = ImageCipher(t1,'decryption',K);
% 
% figure,
% imshow(D5,[])

%Gaussian
C5=C;
g=imnoise (C5,'gaussian',0,0.001);


D5 = ImageCipher(g,'decryption',K);

figure,
imshow(D5,[])
