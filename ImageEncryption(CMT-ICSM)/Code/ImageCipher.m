function varargout = ImageCipher(P,para,K)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the main function to implement image cipher
% P:    the input image;
% para: operation type, 'encryption' or 'decryption';
% K:    the key, when para = 'encryption', it can be given or can not be given; 
%       when para = 'decryption', it must be given;
% varargout: when K is not given, return the result and the randomly
%            generated key; when K is given, return the result.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% to get the key
if ~exist('K','var') && strcmp(para,'encryption')
    K = round(rand(1,256));
    save K;
    OutNum = 2;
elseif ~exist('K','var')  && strcmp(para,'decryption')
    error('Can not dectrypted without a key');
else
    OutNum = 1;
end

%% extract the key
tran = @(K,low,high) sum(K(low:high).*2.^(-(1:(high-low+1))));
x0 = tran(K,1,52);
y0 = tran(K,53,104);
a0 = tran(K,105,156);
T = tran(K,157,208);

Tran = blockproc(K(209:256),[1,16],@(x) bi2de(x));
%% 
if max(P(:)>1)
    F = 256;
else
    F = 2;
end
[r, c] = size(P);

%% generating chaotic sequence one
x = mod(x0 + Tran(1)*T,1);
y = mod(y0 + Tran(1)*T,1);
k = 12 + mod(a0 + Tran(1)*T,4);

 S1 = ChaoticSeq(x,y,k,r,c);
 
 %% generating chaotic sequence two
 x = mod(x0 + Tran(2)*T,1);
 y = mod(y0 + Tran(2)*T,1);
 k = 12 + mod(a0 + Tran(2)*T,4);

 S2 = ChaoticSeq(x,y,k,r,c);
 
  %% generating chaotic sequence Three
 x = mod(x0 + Tran(3)*T,1);
 y = mod(y0 + Tran(3)*T,1);
 k = 12 + mod(a0 + Tran(3)*T,4);

 S3 = ChaoticSeq(x,y,k,r,c);
 
 
 %% To do the encryption/decryption
 C = double(P);
switch para
    case 'encryption'
            % round one
             
             C = ChaoticMagicTrans(C,para,S1);
             C = Substitution(C,para,S1);
             % round two
             C = ChaoticMagicTrans(C,para,S2);
             C = Substitution(C,para,S2);
             
             % round three
             C = ChaoticMagicTrans(C,para,S3);
             C = Substitution(C,para,S3);

    case 'decryption'
             C = Substitution(C,para,S3);
             C = ChaoticMagicTrans(C,para,S3);

        
        
             C = Substitution(C,para,S2);
             C = ChaoticMagicTrans(C,para,S2);
             
             C = Substitution(C,para,S1);
             C = ChaoticMagicTrans(C,para,S1);

end

if F == 256
    C = uint8(C);
else
    C = logical(C);
end

%% 
if OutNum == 1
    varargout{1} = C;
else
    varargout{1} = C;
    varargout{2} = K;
end
end % end of the function ImageCipher

%%
function  S = ChaoticSeq(x,y,k,r,c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is to generate chaotic matrix using 
% 2D Sine Logistic modulation map with the given initial condition
% and size
% x,y,a: the given initial condition;
% r,c; the row and column number of the matrix
%
% S: the generated chaotic matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X = zeros(1,r*c);
Y = X;

% exclude the first 2000 iteration values
% for m = 1:2000
%     x = a*(sin(pi*y)+3)*x*(1-x);
%     y = a*(sin(pi*x)+3)*y*(1-y);
% end

for m = 1:r*c
    x = cos(2^(k+(1-5*cos(y)-5*cos(x))));
    y = cos(2^(k+x+0.3));
    X(m) = x;
    Y(m) = y;
end

X = reshape(X,[r,c]);
Y = reshape(Y,[r,c]);

S = X+Y;        %S的所有元素均在[1,2]中
end % end of the function ChaoticSeq

function C = ChaoticMagicTrans(P,para,S)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is to do circle magic tranform (CMT)
% P: input image ;
% para: operation type, 'encryption' or 'decryption';
% S: input chaotic matrix, the same size as P
%
% C: CMT result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

[r,c] = size(P);

[X,S_c] = sort(S,1);

C = zeros(r,c);

switch para
    case 'encryption'
        for m = 1:r
            for n = 1:c
                C(S_c(m,n),n) = P(S_c(m,  mod(n+  m -1,c)+1)     ,mod(n+m-1,c)+1);
            end
        end
    case 'decryption'

            for m = 1:r
                for n = 1:c
                    C(S_c(m,n),n) = P(S_c(m,  mod(n+ c-  m -1,c)+1)     ,mod(n+ c -  m-1,c)+1);
                end
            end
end
end % end of the function ChaoticMagicTrans

function C = Substitution(P,para,S)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is to do substitution
% P: input image ;
% para: operation type, 'encryption' or 'decryption';
% S: input chaotic matrix, the same size as P
%
% C: substitution result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
P = double(P);
[r,c] = size(P);

if (max(P(:))) > 1
    F = 256;
else
    F = 2;
end


S = floor(S.*2^32);
S = mod(S(:,:), F);

C = zeros(r,c);
T = zeros(r,c);

switch para
    case 'encryption'
        % row substitution
        for m = 1:r
            for n = 1:c
                  if n == 1
                      T(m,n) = mod(P(m,n) + S(m,n)+P(m,c) , F);
                  else
                      T(m,n) = mod(P(m,n) + S(m,n)+T(m,n-1) , F);
                  end
            end
        end
         % column substitution
        for n = 1:c
            for m = 1:r
                  if m == 1
                      C(m,n) = mod(T(m,n)+S(m,n) + T(r,n), F);
                  else
                      C(m,n) = mod(T(m,n)+S(m,n)+C(m-1,n), F);
                  end
            end
        end
        
    case 'decryption'
         for n = 1:c
            for m = r:-1:1
                  if m == 1
                      T(m,n) = mod(P(m,n)-S(m,n)-T(r,n), F);
                  else
                      T(m,n) = mod(P(m,n)-S(m,n)-P(m-1,n), F);
                  end
            end
         end
         for m = 1:r
            for n = c:-1:1
                if n == 1
                   C(m,n) = mod(T(m,n) - S(m,n) - C(m,c), F);
                else
                   C(m,n) = mod(T(m,n) - S(m,n) - T(m,n-1), F);
                end
            end
         end
end
end % end of the function Substitution


    



