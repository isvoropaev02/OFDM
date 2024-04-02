%code to simulate a QPSK signal through multipath Rayleigh channel

%2024.03.26

clear all, clc, close all

signal_length = 128;
SNR_dB = 20;

%QPSK signal
signal_r=2*(rand([signal_length,1])>0.5)-1;
signal_i=2*(rand([signal_length,1])>0.5)-1;
QPSK=signal_r+1i*signal_i;
size(QPSK)

%td_qpsk = ifft(QPSK);

figure
plot(real(td_qpsk))
plot(imag(td_qpsk))

figure
plot(real(QPSK), imag(QPSK), "*")

%add AWGN noise
%signal_power = sum(abs(QPSK).^2)/length(QPSK);
signal_power = ((QPSK)' *(QPSK) ) / signal_length;
n0 = sqrt(0.5)*(randn(1,length(QPSK))+1i*randn(1,length(QPSK))); % the power of noise here =1
noise_power_lin = signal_power*10^(-SNR_dB/10);
noise = sqrt(noise_power_lin)*n0; % noise normalized to needed power
size(noise)

%--------
%multipath Rayleigh channel

path_delay=[1 5 10];
path_gain_db=[0 -20 -30];
%path_gain_db=[0 -99 -99]; %single path
L=length(path_delay);
h(path_delay(end)) = 1i*0;
path_gain_lin=10.^(path_gain_db/10);
temp=randn(1,L)+1i*randn(1,L);
for k=1:L
  h(path_delay(k))=sqrt(path_gain_lin(k)/2).*real(temp(k))+1i*sqrt(path_gain_lin(k)/2).*imag(temp(k));
end %for

%h = [1 0 0 0 0.1];
fading=conv(QPSK, h, "same")';
size(fading)

%--------
figure
plot(real(fading), imag(fading), "*")


%add AWGN noise
received = fading+noise; %received signal (channel & noise)
size(received)

figure
plot(real(received), imag(received), "*")

figure
%original signal
subplot(211)
hold on
plot(abs(QPSK))
plot(real(QPSK))
plot(imag(QPSK))
plot(abs(noise))

%received signal (channel & noise)
subplot(212)
hold on
plot(abs(received))
plot(real(received))
plot(imag(received))

disp("DONE")
%{

%}