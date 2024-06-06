clear all; close all;
% estimation of PSD of single transmitter output OFDM signal
% 06.06.2024.

num_of_frames = 100;
M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM

% values from IEEE 802.11a for 20 MHz band
Bw = 20*10^6; % Hz -- Bandwidth
fr_len = 64; % the length of OFDM frame
delta_f = Bw/fr_len; % Hz -- band between neighbouring subcarriers (312.5 kHz)
Ts = 1/delta_f; % sec -- duration of the frame (3.2 us)
delta_t = 1/Bw; % sec -- time interval between signal samples 
cp_length = fr_len/2; % the size of cyclic prefix (1.6 us)
guard_bands = [1 29 30 31 32 33 34 35 36];% guard band {-32 -31 -30 -29 0 28 29 30 31} subcarriers


%% forming output signal
full_signal = zeros([fr_len+cp_length,num_of_frames]);
for k=1:1:num_of_frames
    message = randi([0 M-1], fr_len-length(guard_bands), 1); % decimal information symbols
    info_frame = generate_information_frame(message, M, guard_bands); % creating frame
    info_frame_td = add_cyclic_prefix(ifft(info_frame).*fr_len, cp_length);
    full_signal(:,k) = info_frame_td;
end

full_signal = reshape(full_signal, [], 1);

%% Using pwelch to estimate PSD
[psd, freq] = pwelch(full_signal,[],[],[], Bw); % Hamming window, two-sided psd estimate, 50% overlap 

figure(1)
plot(freq*1e-6 - 10, fftshift(10*log10(psd)))
xlabel('Frequency [MHz]')
ylabel('PSD [dB]')
title('Welch’s power spectral density estimate')



