clear all; close all; clc
%pkg load communications

%% parameters
rng(1);

num_of_frames = 8;

M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
fr_len = 1024; % the length of OFDM frame
path_delay = {[1 12 13], [1 3 9 10]}; % array of signal arriving delays
path_gain_db = {[0 -8 -23], [0 -7 -15 -17]}; % average level of arriving signals in dB
cp_length = fr_len/2; % the size of cyclic prefix
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

ber_ZF_MIMO = zeros(length(SNR_dB), 1);
ber_MMSE_MIMO = zeros(length(SNR_dB), 1);
evm_ZF_MIMO = zeros(length(SNR_dB), 1);
evm_MMSE_MIMO = zeros(length(SNR_dB), 1);

for k = 1:1:length(SNR_dB)
%     [ber_ZF_SISO(k), evm_ZF_SISO(k), ber_MMSE_SISO(k), evm_MMSE_SISO(k)] = ...
%         run_SISO_model(M, fr_len, SNR_dB(k), path_delay_11, path_gain_db_11, cp_length, guard_bands);
%     [ber_ZF_SIMO(k), evm_ZF_SIMO(k), ber_MMSE_SIMO(k), evm_MMSE_SIMO(k)] = ...
%         run_SIMO_model(M, fr_len, SNR_dB(k), path_delay_11, path_gain_db_11, path_delay_21, path_gain_db_21 , cp_length, guard_bands);
    for ke = 1:1:num_of_frames
         [ber_ZF_SISO_temp, evm_ZF_SISO_temp, ber_MMSE_SISO_temp, evm_MMSE_SISO_temp] = ...
            run_SISO_model(M, fr_len, SNR_dB(k), path_delay{1,1}, path_gain_db{1,1}, cp_length, guard_bands);
         [ber_ZF_SIMO_temp, evm_ZF_SIMO_temp, ber_MMSE_SIMO_temp, evm_MMSE_SIMO_temp] = ... 
             run_SIMO_model(M, fr_len, SNR_dB(k), path_delay{1,1}, path_gain_db{1,1}, path_delay{1,2}, path_gain_db{1,2} , cp_length, guard_bands);
         [ber_ZF_MIMO_temp, evm_ZF_MIMO_temp, ber_MMSE_MIMO_temp, evm_MMSE_MIMO_temp] = ... 
             run_MIMO_model(M, fr_len, SNR_dB(k), path_delay, path_gain_db, cp_length, guard_bands);
         ber_ZF_SISO(k) = ber_ZF_SISO(k) + ber_ZF_SISO_temp;
         evm_ZF_SISO(k) = evm_ZF_SISO(k) + evm_ZF_SISO_temp;
         ber_MMSE_SISO(k) = ber_MMSE_SISO(k) + ber_MMSE_SISO_temp;
         evm_MMSE_SISO(k) = evm_MMSE_SISO(k) + evm_MMSE_SISO_temp;
         ber_ZF_SIMO(k) = ber_ZF_SIMO(k) + ber_ZF_SIMO_temp;
         evm_ZF_SIMO(k) = evm_ZF_SIMO(k) + evm_ZF_SIMO_temp;
         ber_MMSE_SIMO(k) = ber_MMSE_SIMO(k) + ber_MMSE_SIMO_temp;
         evm_MMSE_SIMO(k) = evm_MMSE_SIMO(k) + evm_MMSE_SIMO_temp;
         ber_ZF_MIMO(k) = ber_ZF_MIMO(k) + ber_ZF_MIMO_temp;
         evm_ZF_MIMO(k) = evm_ZF_MIMO(k) + evm_ZF_MIMO_temp;
         ber_MMSE_MIMO(k) = ber_MMSE_MIMO(k) + ber_MMSE_MIMO_temp;
         evm_MMSE_MIMO(k) = evm_MMSE_MIMO(k) + evm_MMSE_MIMO_temp;
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
ber_ZF_MIMO = ber_ZF_MIMO./num_of_frames;
ber_MMSE_MIMO = ber_MMSE_MIMO ./ num_of_frames;
evm_ZF_MIMO = evm_ZF_MIMO ./ num_of_frames;
evm_MMSE_MIMO = evm_MMSE_MIMO ./ num_of_frames;

%% plotting results

figure()
plot(SNR_dB, ber_ZF_SISO, 'DisplayName', 'Zero-Forcing (SISO)', 'LineWidth',2)
hold on
plot(SNR_dB, ber_MMSE_SISO, 'DisplayName', 'MMSE (SISO)', 'LineWidth',2)
plot(SNR_dB, ber_ZF_SIMO, 'DisplayName', 'Zero-Forcing (SIMO)', 'LineWidth',2)
plot(SNR_dB, ber_MMSE_SIMO, 'DisplayName', 'MMSE (SIMO)', 'LineWidth',2)
plot(SNR_dB, ber_ZF_MIMO, 'DisplayName', 'Zero-Forcing (MIMO)', 'LineWidth',2)
plot(SNR_dB, ber_MMSE_MIMO, 'DisplayName', 'MMSE (MIMO)', 'LineWidth',2)
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
plot(SNR_dB, 20*log10(evm_ZF_MIMO), 'DisplayName', 'Zero-Forcing (MIMO)')
plot(SNR_dB, 20*log10(evm_MMSE_MIMO), 'DisplayName', 'MMSE (MIMO)')
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

