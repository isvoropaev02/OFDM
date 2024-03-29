% 25.03.24
% result of each block is written into .txt file

clear all; close all; clc
%% parameters
M = 16; % e.g. QAM-16 
N_inf = 16; % number of information symbols (number of subcarriers) in the frame
fr_len = 32; % the length of OFDM frame
pilots = [1; 1j; -1; -1j]; % pilots
nulls_idx = [1, 2, fr_len/2, fr_len-1, fr_len]; % indexes of nulls
SNR = 20; % [dBW] the signal power is normalized to 1 W

%% message to transmit and recieve
message = randi([0 M-1], N_inf, 1); % decimal information symbols
writematrix(message, "message.txt", "Delimiter", ",")

%% Frame in frequency domain
frame = generate_frame(message, M, N_inf, fr_len, nulls_idx, pilots); % creating frame
writematrix([real(frame), imag(frame)], "frame.txt", "Delimiter", ",")

%% Converting to Time domain
frame_td = ifft(frame);
writematrix([real(frame_td), imag(frame_td)], "frame_td.txt", "Delimiter", ",")

%% Add the AWGN
frame_td_noise = awgn(frame_td, SNR);
writematrix([real(frame_td_noise), imag(frame_td_noise)], "frame_td_noise.txt", "Delimiter", ",")

%% Converting to Frequency domain
frame_fd_noise = fft(frame_td_noise);
writematrix([real(frame_fd_noise), imag(frame_fd_noise)], "frame_fd_noise.txt", "Delimiter", ",")

%% Decoded message from frame in frequency domain
decoded_message = decode_frame(frame_fd_noise, M, N_inf, fr_len, nulls_idx, pilots); % decoding frame
writematrix(decoded_message, "decoded_message.txt", "Delimiter", ",")
