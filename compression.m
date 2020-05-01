% clear all;
close all;
 
clc;
 
img=imread('img.tif');                 % Read Image
 
img=imresize(img,[64,64]);
 
imshow(img);                            % Show Image
title('Original Image');
 
% Initialize Variables
 
dcode=[];
myimg=zeros(8,8);
dimg=zeros(8,8);
q=zeros(8,8);
I=eye(8);
[r,c]=size(img);
img1=zeros(r,c);
 
% Quality Matrix
for i=1:8
    q(1:i,i)=2^(i-1);
    q(i,1:i)=2^(i-1);
end
 
dimg=dct(I);                           % Discrete Cosine Transform of Identity Matrix
idimg=dimg

';      % Transpose of DCT
% DCT + Quantization + Zigzag
for i=1:8:r
  for j=1:8:c
     cimg=double(img((i:i+7),(j:j+7)));  % Windowing
     cimg1=cimg*dimg;
     cimg2=cimg1*idimg;
     cimg3=cimg2./q;                        % Quantization
     img1((i:i+7),(j:j+7))=cimg3;
 
  end
end
 
zimg=(zigzag(img1)).';              % Zigzag Transformation
 
DPCM_code=DPCM(zimg);                           % DPCM = Diffrential Pulse Code Modulation
 
RLE_Code=RLEncoding(DPCM_code);        % Run Length Encoding
 
[H_Code,DIC]=Huffman_Coding(RLE_Code);         % Huffman Encoding
 
%------------ Decoding --------------%
 
% Huffman Decoding
H_Decode=huffmandeco(H_Code,DIC);
 
% RLE Decoding
RLE_Decode=RLDecoding(H_Decode);
 
% DPCM Decoding
DPCM_Decoded=DPCM_Decoding(RLE_Decode);
 
% Inverse Zigzag Transform
IZ_Code=izigzag(double(DPCM_Decoded),64,64);
IZ_Code=IZ_Code;

% Dequantization
DeQ_Code=zeros(r,c);
 
for i=1:8:r
  for j=1:8:c
      Q_win=IZ_Code((i:i+7),(j:j+7));       % Windowing + Dequantization
      Q_win1=Q_win.*q;  
      Q_win2=Q_win1*idimg;
      Q_win2=Q_win2*dimg;
      DeQ_Code((i:i+7),(j:j+7))=Q_win2;
  end
end
 
figure;
imshow(DeQ_Code,[]);
title('Decoded Image');
 
 
function [comp, dict] = Huffman_Coding(x)
 
 
input_matrix = x;
 
symbols = unique(input_matrix);
L = length(symbols);
m = size(input_matrix, 1);
n = size(input_matrix, 2);
symbols = reshape(symbols, 1, L);
if length(symbols) < 2
    comp = 0;
    dict = [0 1];
    return;
end
probs = histc(input_matrix(:),symbols)./(m*n);
s = round(sum(probs)); % round to prevent an inequation 1 ~= 1.0000
if (s ~= 1)
    %%%%%%%%%%%
    end
    [dict, avglen] = huffmandict(symbols, probs);
    comp = huffmanenco(input_matrix(:),dict);
 
end
 
function y=zigzag(x)
    % transform a matrix to the zigzag format%
    x=reshape(1:16,[4 4]);
    [row col]=size(x);
    if row~=col
        disp('toZigzag() fails Must be a square matrix');
        return;
        end;
        y=zeros(row*col,1);
        count=1;
        for s=1:row
            if mod(s,2)==0
                for m=s:-1:1
                    y(count)=x(m,s+1-m);
                    count=count+1;
                end;

    else
        for m=1:s
            y(count)=x(m,s+1-m);
            count=count+1;
            end;
        end;
    end;
    if mod(row,2)==0
        flip=1;
    else
        flip=0;
        end;
        for s=row+1:2*row-1
    if mod(flip,2)==0
        for m=row:-1:s+1-row
            y(count)=x(m,s+1-m);
            count=count+1;
        end;
    else
        for m=row:-1:s+1-row
            y(count)=x(s+1-m,m);
            count=count+1;
        end;
    end;

    flip=flip+1;
    end
    end
 
function output = izigzag(in, vmax, hmax)
 
% initializing the variables
%----------------------------------
h = 1;
v = 1;
 
vmin = 1;
hmin = 1;
 
output = zeros(vmax, hmax);

i = 1;
%----------------------------------
 
while ((v <= vmax) & (h <= hmax))
 
    if (mod(h + v, 2) == 0)                % going up
 
        if (v == vmin)
            output(v, h) = in(i);
            if (h == hmax)
          v = v + 1;
        else
              h = h + 1;
            end;
 
            i = i + 1;
 
        elseif ((h == hmax) & (v < vmax))
            output(v, h) = in(i);
            i;
            v = v + 1;
            i = i + 1;
 
        elseif ((v > vmin) & (h < hmax))
            output(v, h) = in(i);
            v = v - 1;
            h = h + 1;
            i = i + 1;
        end;
        
    else                                   % going down
 
       if ((v == vmax) & (h <= hmax))
            output(v, h) = in(i);
            h = h + 1;
            i = i + 1;
        
       elseif (h == hmin)
            output(v, h) = in(i);
 
            if (v == vmax)
          h = h + 1;
        else
              v = v + 1;
            end;
 
            i = i + 1;
 
       elseif ((v < vmax) & (h > hmin))
            output(v, h) = in(i);
            v = v + 1;
            h = h - 1;
            i = i + 1;
        end;
 
    end;
 
    if ((v == vmax) & (h == hmax))
        output(v, h) = in(i);
        break
    end;
 
end;
end
 
function y= RLEncoding(sig)
k=1;
c=1;
 
for i=1:length(sig);    
    f(k,1)=sig(i);
    
     if (i==length(sig))
        f(k,2)=c;
     else if(sig(i)==sig(i+1))
        c=c+1;
    else
        f(k,2)=c;
        k=k+1;
        c=1;
         end 
     end
end
 
code=[];
for i=1:length(f);
   code=[code,f(i,1),f(i,2)];   
end
 
y=code;
end
 
function y= RLDecoding(sig)
k=1;
c=1;
code=[];
 
siga=sig;
 
for i=2:2:length(siga);
    for j=1:siga(i)
        code=[code,siga(i-1)];
    end
end
 
y=code;
end
 
function y= DPCM(code)
 
dcode=[];
for i=1:length(code)
    if(i==1)
      dcode(i)=code(i);
    else
      dcode(i)=code(i)-code(i-1);
    end 
end
y=dcode;
end
 
function y= DPCM_Decoding(code)
 
dcode=[];
for i=1:length(code)
    if(i==1)
      dcode(i)=code(i);
    else
      dcode(i)=code(i)+dcode(i-1);
    end 
end
y=dcode;
end
