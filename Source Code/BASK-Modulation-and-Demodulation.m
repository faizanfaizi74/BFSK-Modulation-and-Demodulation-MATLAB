clc; close all; clear all;

%if the input is x with sampling frequency fs
%%%%%%%%%%%%%% Input Signal %%%%%%%%%%%%%%%%%%

[x, fs] = audioread('counting0.wav');       % Input Signal
%---------------------------------------------------------------
% Plotting Input Signal
l1=length(x);
t1=-((l1-1)/2):1:((l1-1)/2);
t1=t1';
figure
subplot(2,1,1)
plot(t1,x);
title('Input Signal'), xlabel('time (sec)'), ylabel('y(t)');
%---------------------------------------------------------------
%%%%%%%%%%%%%% Quantization and PCM Encoding %%%%%%%%%%%%%%%%%%

n = 4;                       %the number of bits for PCM encoding;
L =2^n;

t = [0:1:length(x)-1]/fs;
xmax=max(max(x));
xmin=min(min(x));
del=(xmax-xmin)/L;
partition=xmin:del:xmax;
codebook=xmin-(del/2):del:xmax+(del/2);
[indx1,quantv1]=quantiz(x(:,1),partition,codebook);
%[indx2,quantv2]=quantiz(x(:,2),partition,codebook); % if two channels are
                                                     % to be quantized

for i=1:length(indx1)
    if(indx1(i)~=0)
        indx1(i) = indx1(i)-1;
    end
end
for i=1:length(quantv1)
    if(quantv1(i)==xmin-(del/2))
        quantv1(i)=xmin+(del/2);
    end
end

code=de2bi(indx1,'left-msb');
k=1;
xpcm = zeros(length(indx1)*n,1);
for i=1:length(indx1)
    for j=1:n
        xpcm(k)=code(i,j);
        k=k+1;
    end
end

%-------------------------------------------------
%%%%%%%%%%%%%% Channel Encoding %%%%%%%%%%%%%%%%%%

M = 3;
n1 = 2^M-1;                % Code length
k1 = n1-M;                  % Message length

data = reshape(xpcm,length(xpcm)/k1, k1);
encData = encode(data,n1,k1,'hamming/binary');
encData1 = reshape(encData, length(encData)*n1,1);


%------------------------------------------------
%%%%%%%%%%%%%% BASK Modulation %%%%%%%%%%%%%%%%%%

%%%input is encoder output;

Tb = 0.1; %bit interval
ts = Tb/100;
fs = 1/ts;
nb = Tb/ts; %number of samples in one bit interval
fc = fs/10;

xmod = zeros(length(encData1)*nb,1);
j = 1;
for i = 1:nb:length(xmod)
    xmod(i:i+(nb-1)) = encData1(j);
    j = j+1;
end

t = 0:ts:(length(xmod)*ts)-ts;
car1 = cos(2*pi*fc*t);
xmodbask = xmod.*car1';

%--------------------------------------------------
%%%%%%%%%%%%%% Adding Gausian Noise %%%%%%%%%%%%%%%

xmodbask = awgn(xmodbask,50);

%--------------------------------------------------
%%%%%%%%%%%%%% BASK Demodulation %%%%%%%%%%%%%%%%%%

xdemodbask = abs(xmodbask);

%nb is the number of samples in one bit interval

xdemod = zeros(length(xdemodbask)/nb,1);
thresh1 = (max(xdemodbask)-min(xdemodbask))/2;
j = 1;
for i = 1:nb:length(xdemodbask)
    av = sum(xdemodbask(i:i+(nb-1)))/nb;
    if av >= thresh1
        xdemod(j) = 1;
    else
        xdemod(j) = 0;
    end
    j = j+1;
end

%--------------------------------------------------
%%%%%%%%%%%%%% Channel Decoding %%%%%%%%%%%%%%%%%%

%if the input is named xdemod

decData1 = reshape(xdemod,length(xdemod)/n1,n1);
decData2 = decode(decData1,n1,k1,'hamming/binary');
numerr = biterr(data,decData2)
decData = reshape(decData2,length(decData2)*k1,1);

%--------------------------------------------------
%%%%%%%%%%%%%% PCM Decoding %%%%%%%%%%%%%%%%%%

%if the input is named decData

xpcm1 =reshape(decData,n,length(decData)/n);
index =bi2de(xpcm1','left-msb');
xdecoded = codebook(index+1);

% Plotting Decoded Signal
l1=length(xdecoded);
t1=-((l1-1)/2):1:((l1-1)/2);
t1=t1';
subplot(2,1,2)
plot(t1,xdecoded);
title('Decoded Signal'), xlabel('time (sec)'), ylabel('y(t)');



%{
    In this task, we have used a voice signal for a digital communication
    through Binary Amplitude Shift Keying Modulation and Demodulation
    Scheme. We integrated each communication block and observed the output.
    The output was almost similar after demodulation.
    
    After this we added a Gausian Noise signal at modulated signal and
    observed the SNR at output signal. Increasing SNR gives more close
    results while decresing it adds noise to the output signal.
%}