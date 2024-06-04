%Rayleigh
%code to simulate a QPSK signal through 3-path Rayleigh channel
%https://www.researchgate.net/post/Simulate-Rayleigh-channel-using-Matlab
%2024.03.26 F-up/down
%04.07 conv size fix
%04.17 frequency conversion fix -> 0.5*pi

clear all, clc, close all

signal_length = 64;
SNR_dB = 30;
P = 1;

signal_r=2*(rand([signal_length,1])>0.5)-1;
signal_i=2*(rand([signal_length,1])>0.5)-1;
QPSK=signal_r+1i*signal_i;

%hold on
%plot(abs(QPSK))
%plot(real(QPSK))
%plot(imag(QPSK))
%%plot(abs(fft(QPSK, 8*length(QPSK))))
%return

% frequency upconversion

interpol = 16;

ll = interpol*length(QPSK);
ii = 1:ll;
size(ii)
size(QPSK)
%QPSK2 = []
QPSK2 = interpft(QPSK, ll);
size(QPSK2)

f = 0.5; % -1<f<1

% frequency upconversion
%QPSK2 = QPSK2.*exp(8*(interpol/Ls)*1i*ii');
QPSK2 = QPSK2.*exp(f*pi*1i*ii');

figure(1)
plot(abs(fft(QPSK2, 8*length(QPSK2))))

% frequency downconversion
QPSK2 = QPSK2.*exp(-f*0.5*pi*1i*ii');
QPSK2 = resample(QPSK2, 1, interpol);

figure(2)
plot(abs(fft(QPSK2, 8*length(QPSK2))))
% hold on
% plot(abs(QPSK2))
% plot(real(QPSK2))
% plot(imag(QPSK2))

%return

Es=((QPSK)' *(QPSK) ) / signal_length;
N0=Es/10^(SNR_dB/10);

h=sqrt(P/2)*(randn(1,3)+1i*randn(1,3));
h(2) = 0;
h(3) = 0.1*h(3);

fading=conv(QPSK , h, "full");
fading = fading(1:length(QPSK)); %conv size fix

noise=sqrt(N0/4)*( randn(length(fading),1)+1i*randn(length(fading),1) );

received = fading+noise;

figure(3)
subplot(211)
hold on
plot(abs(QPSK))
plot(real(QPSK))
plot(imag(QPSK))
plot(abs(noise))

subplot(212)
hold on
plot(abs(received))
plot(real(received))
plot(imag(received))
