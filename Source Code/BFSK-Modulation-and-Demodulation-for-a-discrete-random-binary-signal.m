clc; close all; clear all;

%%%%%%%%%%%%%% Input Signal %%%%%%%%%%%%%%%%%%

N = 8;   % The number of bits
x = round(rand(1,N));  % Generate a random bit stream as Input Signal
bp=.000001;            % bit period
disp(' Binary information at Trans mitter :');
disp(x);
n = length(x);
t = 0:.01:n;   
%---------------------------------------------------------------
% Bit Streaming
bit=[]; 
for n=1:1:length(x)
    if x(n)==1;
       se=ones(1,100);
    else x(n)==0;
        se=zeros(1,100);
    end
     bit=[bit se];

end

% Plotting Input Signal
t1=bp/100:bp/100:100*length(x)*(bp/100);
subplot(211);
plot(t1,bit,'lineWidth',2.5);grid on;
axis([ 0 bp*length(x) -.5 1.5]);
title('Binary Input Signal'), ylabel('amplitude(volt)'), xlabel('time(sec)');

%------------------------------------------------
%%%%%%%%%%%%%% BFSK Modulation %%%%%%%%%%%%%%%%%%

% input is bit output;

Tb = 0.1; %bit interval
ts = Tb/100;
fs = 1/ts;  % Sample rate (Hz)
nb = Tb/ts; %number of samples in one bit interval
fc = fs/10;

M = 2;        % Modulation order
freqsep = 10; % Frequency separation (Hz)
nsamp = 8;    % Number of samples per symbol

xmodfask = fskmod(bit,M,freqsep,nsamp,fs);

%--------------------------------------------------
%%%%%%%%%%%%%% Adding Gausian Noise %%%%%%%%%%%%%%%

xmodfask = awgn(xmodfask,25);

%--------------------------------------------------
%%%%%%%%%%%%%% FASK Demodulation %%%%%%%%%%%%%%%%%%

xdemod = fskdemod(xmodfask,M,freqsep,nsamp,fs);

%--------------------------------------------------
%%%%%%%%%%%%%% Demodulation Signal Represenatation %%%%%%%%%%%%%%%%%%

bit=[];
for n=1:length(xdemod);
    if xdemod(n)==1;
       se=ones(1,100);
    else xdemod(n)==0;
        se=zeros(1,100);
    end
     bit=[bit se];

end

t4=bp/100:bp/100:100*length(xdemod)*(bp/100);
subplot(212)
plot(t4,bit,'LineWidth',2.5);grid on;
axis([ 0 bp*length(xdemod) -.5 1.5]);
title('Demodulated Signal');


%{
    In this task, we have used a random discrete signal and did bit stream.
    We used code for representation of this random binary stream.
    After this we have used BFSK modulation by using MATLAB built-in command
    fskmod and then demodulated the signal using built-in command fskdemod.
    After demodulation we represented the original signal again with bit streaming.
    We have also analyzed the results by adding Gaussian Noise.
%}