% main performance file
% result of each block is written into .txt file

% 11.08.2024
% nuber of Rx and Tx antennas can be arbitrary

clear all; close all; clc
addpath(genpath('src'))
%pkg load communications

%% parameters
rng(1); % random seed setter (for repeating the same results)

M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
SNR_dB = 23; % [dBW] the signal power is normalized to 1 W
path_delay = {[1 20 50], [1 30 85]}; % array of signal arriving delays
path_gain_db = {[0 -7 -16], [0 -5 -19 -23]}; % average level of arriving signals in dB
Nr = 2; % number of recieve antennas
Nt = 2; % number of transmitt antennas

% spectral parameters
channel_bw = 5*1e6; % Hz
scs = 15*1e3; % Hz - subcarrier spacing

% values from 3GPP TS 38.104
[fr_len, n_ifft, delta_t, cp_len, guard_bands] = get_params_from_nr_configuration(channel_bw, scs);


%% Tx signals
[info_frame_td,message,info_frame] = MIMO_generate_output_info_signal(Nt, M, fr_len, n_ifft, cp_len, guard_bands);
[pilots_frame_td, pilots_frame] = MIMO_generate_output_pilot_signal(Nt, fr_len, n_ifft, cp_len, guard_bands);
fprintf('Power_Tx = %f\n', MIMO_signal_power(info_frame_td));

%% Channel
h_full = MIMO_Rayleigh_channel(path_delay, path_gain_db, Nr, Nt);
% plot IR
figure()
subplot(211)
stem(delta_t*(0:1:size(h_full,1)-1)*1e6,abs(h_full(:,1,1)),'.', 'DisplayName', 'h11')
hold on
stem(delta_t*(0:1:size(h_full,1)-1)*1e6,abs(h_full(:,Nr, Nt)),'.', 'DisplayName', 'h22')
xlabel('Time [us]')
ylabel('h(t), abs')
legend()
title('Impulse response of the channel')
subplot(212)
stem(delta_t*(0:1:size(h_full,1)-1)*1e6,rad2deg(angle(h_full(:,1,1))),'.')
hold on
stem(delta_t*(0:1:size(h_full,1)-1)*1e6,rad2deg(angle(h_full(:,Nr, Nt))),'.')
xlabel('Time [us]')
ylabel('h(t), phase (deg)')
grid('on')

info_frame_td_channel = MIMO_convolution(info_frame_td,h_full);
pilots_frame_td_channel = zeros(size(pilots_frame_td,1),size(h_full,2),size(pilots_frame_td,3));
for id_t = 1:Nt
    pilots_frame_td_channel(:,:,id_t) = MIMO_convolution(pilots_frame_td(:,:,id_t),h_full);
end
fprintf('Power_Channel = %f\n', MIMO_signal_power(info_frame_td_channel));

%% AWGN
info_frame_td_noise = MIMO_AWGN(info_frame_td_channel, SNR_dB, Nr);
pilots_frame_td_noise = zeros(size(pilots_frame_td_channel));
for id_t = 1:Nt
    pilots_frame_td_noise(:,:,id_t) = MIMO_AWGN(pilots_frame_td_channel(:,:,id_t), SNR_dB, Nr);
end
fprintf('Power_Rx = %f\n', MIMO_signal_power(info_frame_td_noise));

%% Rx signals
info_frame_fd = MIMO_Rx_signal_to_fd(info_frame_td_noise, fr_len, cp_len, guard_bands);
pilots_frame_fd = zeros(fr_len-length(guard_bands), size(pilots_frame_td_noise,2), size(pilots_frame_td_noise,3));
for id_t = 1:Nt
    pilots_frame_fd(:,:,id_t) = MIMO_Rx_signal_to_fd(pilots_frame_td_noise(:,:,id_t), fr_len, cp_len, guard_bands);
end

figure()
plot(real(reshape(info_frame_fd, [], 1)), imag(reshape(info_frame_fd, [], 1)), "*", 'DisplayName','information frame', 'Color', 'black')
hold on
plot(real(reshape(pilots_frame_fd, [], 1, 1)), imag(reshape(pilots_frame_fd, [], 1, 1)), "*", 'DisplayName','pilots frame', 'Color', 'green')
legend()
xlabel('I')
ylabel('Q')
title("Before equalizer")

%% Channel estimation and Equalizer
info_frame_equalized_ZF = use_ZF_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands);
info_frame_equalized_MMSE = use_MMSE_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands,SNR_dB, 0);

figure()
hold on
plot(real(reshape(info_frame_equalized_ZF, [], 1)), imag(reshape(info_frame_equalized_ZF, [], 1)), "*", 'DisplayName','Zero-Forcing')
plot(real(reshape(info_frame_equalized_MMSE,[],1)), imag(reshape(info_frame_equalized_MMSE,[],1)), "*", 'DisplayName','MMSE')
title("After equalizer")
legend()
xlabel('I')
ylabel('Q')

%% Decoded message from frame in frequency domain (block "Demodulator")
decoded_message_ZF = MIMO_decode_frame(info_frame_equalized_ZF, M); % decoding frame
decoded_message_MMSE = MIMO_decode_frame(info_frame_equalized_MMSE, M);

%% Metrics calculation (blocks "BER" and "EVM")
[ber_ZF, evm_ZF] = MIMO_metrics(message, decoded_message_ZF, M, info_frame_equalized_ZF, info_frame, guard_bands);
[ber_MMSE, evm_MMSE] = MIMO_metrics(message, decoded_message_MMSE, M, info_frame_equalized_MMSE, info_frame, guard_bands);

fileID = fopen('metrics.txt','w');
fprintf(fileID,'%s\t%s\t%s\t%s\n', "BER_ZF", "BER_MMSE", "EVM_ZF", "EVM_MMSE");
fprintf(fileID,'%f\t%f\t%f\t%f\n', ber_ZF, ber_MMSE, evm_ZF, evm_MMSE);
fclose(fileID);


