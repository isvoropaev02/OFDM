clear all; close all; clc
%pkg load communications

%% parameters
rng(2);

num_of_frames = 5;

M = 16; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
fr_len = 2048; % the length of OFDM frame
path_delay_11 = [1 4 15 20]; % array of signal arriving delays
path_gain_db_11 = [0 -7 -15 -40]; % average level of arriving signals in dB
path_delay_21 = [1 3 5]; % array of signal arriving delays
path_gain_db_21 = [-2 -5 -16]; % average level of arriving signals in dB
cp_length = max([fr_len/2 path_delay_11(end) path_delay_21(end)]); % the size of cyclic prefix
guard_bands = [];% пока не делаем [1 2 fr_len-1 fr_len]; % guard band in spectrum
SNR_dB = (1:0.5:25)'; % [dBW] the signal power is normalized to 1 W

%% creating arrays of results
ber_ZF_SISO = zeros(length(SNR_dB), 1);
ber_MMSE_SISO = zeros(length(SNR_dB), 1);
evm_ZF_SISO = zeros(length(SNR_dB), 1);
evm_MMSE_SISO = zeros(length(SNR_dB), 1);

ber_ZF_SIMO = zeros(length(SNR_dB), 1);
ber_MMSE_SIMO = zeros(length(SNR_dB), 1);
evm_ZF_SIMO = zeros(length(SNR_dB), 1);
evm_MMSE_SIMO = zeros(length(SNR_dB), 1);

for k = 1:1:length(SNR_dB)
%     [ber_ZF_SISO(k), evm_ZF_SISO(k), ber_MMSE_SISO(k), evm_MMSE_SISO(k)] = ...
%         run_SISO_model(M, fr_len, SNR_dB(k), path_delay_11, path_gain_db_11, cp_length, guard_bands);
%     [ber_ZF_SIMO(k), evm_ZF_SIMO(k), ber_MMSE_SIMO(k), evm_MMSE_SIMO(k)] = ...
%         run_SIMO_model(M, fr_len, SNR_dB(k), path_delay_11, path_gain_db_11, path_delay_21, path_gain_db_21 , cp_length, guard_bands);
    for ke = 1:1:num_of_frames
        [ber_ZF_SISO_temp, evm_ZF_SISO_temp, ber_MMSE_SISO_temp, evm_MMSE_SISO_temp] = ...
            run_SISO_model(M, fr_len, SNR_dB(k), path_delay_11, path_gain_db_11, cp_length, guard_bands);
         [ber_ZF_SIMO_temp, evm_ZF_SIMO_temp, ber_MMSE_SIMO_temp, evm_MMSE_SIMO_temp] = ... 
             run_SIMO_model(M, fr_len, SNR_dB(k), path_delay_11, path_gain_db_11, path_delay_21, path_gain_db_21 , cp_length, guard_bands);
         ber_ZF_SISO(k) = ber_ZF_SISO(k) + ber_ZF_SISO_temp;
         evm_ZF_SISO(k) = evm_ZF_SISO(k) + evm_ZF_SISO_temp;
         ber_MMSE_SISO(k) = ber_MMSE_SISO(k) + ber_MMSE_SISO_temp;
         evm_MMSE_SISO(k) = evm_MMSE_SISO(k) + evm_MMSE_SISO_temp;
         ber_ZF_SIMO(k) = ber_ZF_SIMO(k) + ber_ZF_SIMO_temp;
         evm_ZF_SIMO(k) = evm_ZF_SIMO(k) + evm_ZF_SIMO_temp;
         ber_MMSE_SIMO(k) = ber_MMSE_SIMO(k) + ber_MMSE_SIMO_temp;
         evm_MMSE_SIMO(k) = evm_MMSE_SIMO(k) + evm_MMSE_SIMO_temp;
    end
end

ber_ZF_SISO = ber_ZF_SISO./num_of_frames;
ber_MMSE_SISO = ber_MMSE_SISO ./ num_of_frames;
evm_ZF_SISO = evm_ZF_SISO ./ num_of_frames;
evm_MMSE_SISO = evm_MMSE_SISO ./ num_of_frames;
ber_ZF_SIMO = ber_ZF_SIMO./num_of_frames;
ber_MMSE_SIMO = ber_MMSE_SIMO ./ num_of_frames;
evm_ZF_SIMO = evm_ZF_SIMO ./ num_of_frames;
evm_MMSE_SIMO = evm_MMSE_SIMO ./ num_of_frames;

%% plotting results

figure()
plot(SNR_dB, ber_ZF_SISO, 'DisplayName', 'Zero-Forcing (SISO)')
hold on
plot(SNR_dB, ber_MMSE_SISO, 'DisplayName', 'MMSE (SISO)')
plot(SNR_dB, ber_ZF_SIMO, 'DisplayName', 'Zero-Forcing (SIMO)')
plot(SNR_dB, ber_MMSE_SIMO, 'DisplayName', 'MMSE (SIMO)')
set(gca, 'YScale', 'log')
xlabel("SNR [dB]")
ylabel("Uncoded BER")
ylim([10^(-3) 1])
legend()

figure()
plot(SNR_dB, 20*log10(evm_ZF_SISO), 'DisplayName', 'Zero-Forcing (SISO)')
hold on
plot(SNR_dB, 20*log10(evm_MMSE_SISO), 'DisplayName', 'MMSE (SISO)')
plot(SNR_dB, 20*log10(evm_ZF_SIMO), 'DisplayName', 'Zero-Forcing (SIMO)')
plot(SNR_dB, 20*log10(evm_MMSE_SIMO), 'DisplayName', 'MMSE (SIMO)')
xlabel("SNR [dB]")
ylabel("EVM [dB]")
legend()

% fileID = fopen('comparison_metrics.txt','w');
% fprintf(fileID,'%s, %s, %s, %s, %s, %s, %s, %s, %s\n', "SNR_dB", ...
%     "BER_ZF_SISO", "BER_MMSE_SISO", "EVM_ZF_SISO", "EVM_MMSE_SISO", ...
%     "BER_ZF_SIMO", "BER_MMSE_SIMO", "EVM_ZF_SIMO", "EVM_MMSE_SIMO");
% fprintf(fileID,'%f, %f, %f, %f, %f, %f, %f, %f, %f\n', [SNR_dB'; ber_ZF_SISO'; ber_MMSE_SISO'; evm_ZF_SISO'; ...
%     evm_MMSE_SISO'; ber_ZF_SIMO'; ber_MMSE_SIMO'; evm_ZF_SIMO'; evm_MMSE_SIMO']);
% fclose(fileID);