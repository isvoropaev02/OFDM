% main performance file
% result of each block is written into .txt file

% 11.06.2024
% nuber of Rx and Tx antennas can be arbitrary

clear all; close all; clc
%pkg load communications

%% parameters
rng(9); % random seed setter (for repeating the same results)

M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
SNR_dB = 20; % [dBW] the signal power is normalized to 1 W
path_delay = {[1 12 13], [1 3 9 10]}; % array of signal arriving delays
path_gain_db = {[0 -8 -23], [0 -7 -15 -17]}; % average level of arriving signals in dB
Nr = 2; % number of recieve antennas
Nt = 2; % number of transmitt antennas

% values from IEEE 802.11a for 20 MHz band
Bw = 20*10^6; % Hz -- Bandwidth
fr_len = 64; % the length of OFDM frame
delta_f = Bw/fr_len; % Hz -- band between neighbouring subcarriers (312.5 kHz)
Ts = 1/delta_f; % sec -- duration of the frame (3.2 us)
delta_t = 1/Bw; % sec -- time interval between signal samples 
cp_length = fr_len/2; % the size of cyclic prefix (1.6 us)
guard_bands = [1 29 30 31 32 33 34 35 36];% guard band {-32 -31 -30 -29 0 28 29 30 31} subcarriers

%% Tx signals
[info_frame_td,message,info_frame] = MIMO_generate_output_info_signal(Nt, M, fr_len, cp_length, guard_bands);
[pilots_frame_td, pilots_frame] = MIMO_generate_output_pilot_signal(Nt, fr_len, cp_length, guard_bands);
fprintf('Power_Tx = %f\n', MIMO_signal_power(info_frame_td));

%% Channel
h_full = MIMO_Rayleigh_channel(path_delay, path_gain_db, Nr, Nt);
% writematrix([real(h_full(:,1,1)), imag(h_full(:,1,1))], "h11.txt", "Delimiter", ",");
% writematrix([real(h_full(:,1,2)), imag(h_full(:,1,2))], "h12.txt", "Delimiter", ",");
% writematrix([real(h_full(:,2,1)), imag(h_full(:,2,1))], "h21.txt", "Delimiter", ",");
% writematrix([real(h_full(:,2,2)), imag(h_full(:,2,2))], "h22.txt", "Delimiter", ",");
% plot IR
figure()
subplot(211)
stem(delta_t*(0:1:size(h_full,1)-1)*1e9,abs(h_full(:,1,1)), 'DisplayName', 'h11')
hold on
stem(delta_t*(0:1:size(h_full,1)-1)*1e9,abs(h_full(:,Nr, Nt)), 'DisplayName', 'h22')
xlabel('Time [ns]')
ylabel('h(t), abs')
legend()
title('Impulse response of the channel')
subplot(212)
stem(delta_t*(0:1:size(h_full,1)-1)*1e9,rad2deg(angle(h_full(:,1,1))))
hold on
stem(delta_t*(0:1:size(h_full,1)-1)*1e9,rad2deg(angle(h_full(:,Nr, Nt))))
xlabel('Time [ns]')
ylabel('h(t), phase (deg)')

info_frame_td_channel = MIMO_convolution(info_frame_td,h_full);
pilots_frame_td_channel = zeros(size(pilots_frame_td,1),size(h_full,2),size(pilots_frame_td,3));
for id_t = 1:Nt
    pilots_frame_td_channel(:,:,id_t) = MIMO_convolution(pilots_frame_td(:,:,id_t),h_full);
end
fprintf('Power_Channel = %f\n', MIMO_signal_power(info_frame_td_channel));

%% AWGN
info_frame_td_noise = MIMO_AWGN(info_frame_td_channel, SNR_dB);
pilots_frame_td_noise = zeros(size(pilots_frame_td_channel));
for id_t = 1:Nt
    pilots_frame_td_noise(:,:,id_t) = MIMO_AWGN(pilots_frame_td_channel(:,:,id_t), SNR_dB);
end
fprintf('Power_Rx = %f\n', MIMO_signal_power(info_frame_td_noise));

%% Rx signals
info_frame_fd = MIMO_Rx_signal_to_fd(info_frame_td_noise, fr_len, cp_length, guard_bands);
pilots_frame_fd = zeros(fr_len-length(guard_bands), size(pilots_frame_td_channel,2), size(pilots_frame_td_channel,3));
for id_t = 1:Nt
    pilots_frame_fd(:,:,id_t) = MIMO_Rx_signal_to_fd(pilots_frame_td_noise(:,:,id_t), fr_len, cp_length, guard_bands);
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
% plot(real(info_frame_equalized_ZF(:,1)), imag(info_frame_equalized_ZF(:,1)), "*", 'DisplayName','Zero-Forcing (UE1)')
% plot(real(info_frame_equalized_ZF(:,2)), imag(info_frame_equalized_ZF(:,2)), "*", 'DisplayName','Zero-Forcing (UE2)')
% plot(real(info_frame_equalized_MMSE(:,1)), imag(info_frame_equalized_MMSE(:,1)), "*", 'DisplayName','MMSE (UE1)')
% plot(real(info_frame_equalized_MMSE(:,2)), imag(info_frame_equalized_MMSE(:,2)), "*", 'DisplayName','MMSE (UE2)')
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


