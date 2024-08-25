% 25.08.2024
% created
clear all; close all; clc
addpath(genpath('src'))

desired_precision = 1e-3;

%% system configuration
config = struct();

config.modulator_order = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
config.SNR_dB = 30; % [dBW] the signal power is normalized to 1 W
config.Nr = 2; % number of recieve antennas
config.Nt = 2; % number of transmitt antennas
config.TDL_channel = "A"; % ["A", "B", "C"]

% spectral parameters
channel_bw = 20*1e6; % Hz
scs = 15*1e3; % Hz - subcarrier spacing
[config.fr_len, config.n_ifft, config.delta_t, config.cp_len, config.guard_bands] = ...
    get_params_from_nr_configuration(channel_bw, scs);

number_of_runs = calculate_number_of_runs(config, desired_precision);

snr_set = 0:3:42;
ber_ZF_final = zeros(length(snr_set),1);
ber_MMSE_final = zeros(length(snr_set),1);
evm_ZF_final = zeros(length(snr_set),1);
evm_MMSE_final = zeros(length(snr_set),1);

for jj=1:length(snr_set)
    fprintf("Running SNR="+string(snr_set(jj))+" dB\n")
    config.SNR_dB = snr_set(jj);

    ber_ZF_temp = zeros(number_of_runs,1);
    ber_MMSE_temp = zeros(number_of_runs,1);
    evm_ZF_temp = zeros(number_of_runs,1);
    evm_MMSE_temp = zeros(number_of_runs,1);

    for ii = 1:number_of_runs
        rng(ii);
        [ber_ZF_temp(ii), evm_ZF_temp(ii), ber_MMSE_temp(ii), evm_MMSE_temp(ii)] = run_model(config);
    end
    ber_ZF_final(jj) = mean(ber_ZF_temp);
    ber_MMSE_final(jj) = mean(ber_MMSE_temp);
    evm_ZF_final(jj) = mean(evm_ZF_temp);
    evm_MMSE_final(jj) = mean(evm_MMSE_temp);
end

figure()
plot(snr_set, ber_ZF_final, 'DisplayName', 'Zero-Forcing (MIMO)')
hold on
plot(snr_set, ber_MMSE_final, 'DisplayName', 'MMSE (MIMO)')
set(gca, 'YScale', 'log')
xlabel("SNR [dB]")
ylabel("Uncoded BER")
%ylim([10^(-3) 1])
legend()
grid('on')

figure()
plot(snr_set, 20*log10(evm_ZF_final), 'DisplayName', 'Zero-Forcing (MIMO)')
hold on
plot(snr_set, 20*log10(evm_MMSE_final), 'DisplayName', 'MMSE (MIMO)')
xlabel("SNR [dB]")
ylabel("EVM [dB]")
grid('on')
legend()