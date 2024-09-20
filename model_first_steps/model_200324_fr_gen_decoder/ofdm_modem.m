clear all; close all; clc
%% parameters
M = 16; % e.g. QAM-16 
N_inf = 16; % number of information symbols (number of subcarriers) in the frame
fr_len = 32; % the length of OFDM frame
pilots = [1; 1j; -1; -1j]; % pilots
nulls_idx = [1, 2, fr_len/2, fr_len-1, fr_len]; % indexes of nulls

%% message to transmit and recieve
message = randi([0 M-1], N_inf, 1); % decimal information symbols

frame = generate_frame(message, M, N_inf, fr_len, nulls_idx, pilots); % creating frame
disp(frame);

decoded_message = decode_frame(frame, M, N_inf, fr_len, nulls_idx, pilots); % decoding frame
disp([message; decoded_message])