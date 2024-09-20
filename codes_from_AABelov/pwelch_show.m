%octave9.10

clear all, clc, close all

%pkg load signal %pwelch

signal_length = 2048;
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
size(ii);
size(QPSK);
%QPSK2 = []
QPSK2 = interpft(QPSK, ll);
size(QPSK2);

f = -0.5; % -1<f<1

% frequency upconversion
%QPSK2 = QPSK2.*exp(8*(interpol/Ls)*1i*ii');
QPSK2 = QPSK2.*exp(f*pi*1i*ii');

%spectum

figure(1)
plot(abs(fft(QPSK2, 8*length(QPSK2))))%, return
title("abs fft")

figure(2)
size(xcorr(QPSK2))
plot( abs( fft( xcorr(QPSK2), 4*length(QPSK2) ) ) )
title("abs fft xcorr")


%[SPECTRA,FREQ] = pwelch(X, WINDOW, OVERLAP, NFFT, FS,
% RANGE, PLOT_TYPE, DETREND, SLOPPY)

[SPECTRA,FREQ] = pwelch(QPSK2);

figure(3)
plot(FREQ, SPECTRA)
title("pwelch")%, return


%pwelch =======