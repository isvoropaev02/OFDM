clear all; close all; clc
%pkg load communications

%% parameters
rng(1);

M = 16; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
fr_len = 2048; % the length of OFDM frame
path_delay = [1 4 15 20]; % array of signal arriving delays
path_gain_db = [0 -10 -15 -40]; % average level of arriving signals in dB
cp_length = max([fr_len/2 path_delay(end)]); % the size of cyclic prefix
guard_bands = [];% пока не делаем [1 2 fr_len-1 fr_len]; % guard band in spectrum

SNR_dB = (1:0.5:25)'; % [dBW] the signal power is normalized to 1 W

%% generate channel
h = Rayleigh_channel(path_delay, path_gain_db);
figure
title('Impulse response of the channel')
subplot(211)
stem(abs(h))
xlabel('Time')
ylabel('h(t), abs')
subplot(212)
stem(rad2deg(angle(h)))
xlabel('Time')
ylabel('h(t), phase (deg)')


%% creating arrays of results
ber_ZF = zeros(length(SNR_dB), 1);
ber_MMSE = zeros(length(SNR_dB), 1);
evm_ZF = zeros(length(SNR_dB), 1);
evm_MMSE = zeros(length(SNR_dB), 1);

for k = 1:1:length(SNR_dB)
    [ber_ZF(k), evm_ZF(k), ber_MMSE(k), evm_MMSE(k)] = run_model(M, fr_len, SNR_dB(k), h, cp_length, guard_bands);
end

%% plotting results

figure()
plot(SNR_dB, ber_ZF, 'DisplayName', 'Zero-Forcing')
hold on
plot(SNR_dB, ber_MMSE, 'DisplayName', 'MMSE')
set(gca, 'YScale', 'log')
xlabel("SNR, dB")
ylabel("Uncoded BER")
legend()

figure()
plot(SNR_dB, 20*log10(evm_ZF), 'DisplayName', 'Zero-Forcing')
hold on
plot(SNR_dB, 20*log10(evm_MMSE), 'DisplayName', 'MMSE')
xlabel("SNR, dB")
ylabel("EVM, dB")
legend()


fileID = fopen('comparison_metrics.txt','w');
fprintf(fileID,'%s, %s, %s, %s, %s\n', "SNR_dB","BER_ZF", "BER_MMSE", "EVM_ZF", "EVM_MMSE");
fprintf(fileID,'%f, %f, %f, %f, %f\n', [SNR_dB'; ber_ZF'; ber_MMSE'; evm_ZF'; evm_MMSE']);
fclose(fileID);

