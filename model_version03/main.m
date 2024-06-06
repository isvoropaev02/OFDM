% main performance file
% result of each block is written into .txt file

% 06.06.2024
% time and frequency values are specified

clear all; close all; clc
%pkg load communications

%% parameters
rng(5); % random seed setter (for repeating the same results)

M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
SNR_dB = 20; % [dBW] the signal power is normalized to 1 W
path_delay_11 = [1 3 4 5]; % array of signal arriving delays
path_gain_db_11 = [0 -6 -10 -15]; % average level of arriving signals in dB
path_delay_21 = [1 2 4 6];
path_gain_db_21 = [-2 -4 -14 -17];

% values from IEEE 802.11a for 20 MHz band
Bw = 20*10^6; % Hz -- Bandwidth
fr_len = 64; % the length of OFDM frame
delta_f = Bw/fr_len; % Hz -- band between neighbouring subcarriers (312.5 kHz)
Ts = 1/delta_f; % sec -- duration of the frame (3.2 us)
delta_t = 1/Bw; % sec -- time interval between signal samples 
cp_length = max([fr_len/2 path_delay_11(end) path_delay_21(end)]); % the size of cyclic prefix (1.6 us)
guard_bands = [1 29 30 31 32 33 34 35 36];% guard band {-32 -31 -30 -29 0 28 29 30 31} subcarriers
% frequeny_range = linspace(-Bw/2, Bw/2, fr_len);
% time_range = linspace(0, 3*Ts/2, 3*fr_len/2);

%% message to transmit and recieve (block "Bits stream")
message = randi([0 M-1], fr_len-length(guard_bands), 1); % decimal information symbols

%% Frame in frequency domain (blocks "Modulator" and "Pilot signals")
pilots_frame = generate_pilots_frame(fr_len, guard_bands);
info_frame = generate_information_frame(message, M, guard_bands); % creating frame

figure(1)
hold on
title('Before IDFT')
plot(linspace(-Bw/2, Bw/2-delta_f, fr_len)*10^(-6), fftshift(abs(info_frame)))
xlabel('Frequency, MHz')
ylabel('Power spectrum of output signal')

%% Converting to Time domain and adding cyclic prefix (blocks "IFFT" and "Cyclic prefix")
info_frame_td = add_cyclic_prefix(ifft(info_frame).*fr_len, cp_length);
pilots_frame_td = add_cyclic_prefix(ifft(pilots_frame).*fr_len, cp_length);

fprintf('Power_Tx = %f\n', signal_power(info_frame_td));

%% Channel
h11 = Rayleigh_channel(path_delay_11, path_gain_db_11);
h21 = Rayleigh_channel(path_delay_21, path_gain_db_21);
% plot IR
figure(2)
subplot(211)
stem(delta_t*(0:1:path_delay_11(end)-1)*1e9,abs(h11), 'DisplayName', 'h11')
hold on
stem(delta_t*(0:1:path_delay_21(end)-1)*1e9,abs(h21), 'DisplayName', 'h21')
xlabel('Time [ns]')
ylabel('h(t), abs')
legend()
title('Impulse response of the channel')
subplot(212)
stem(delta_t*(0:1:path_delay_11(end)-1)*1e9,rad2deg(angle(h11)))
hold on
stem(delta_t*(0:1:path_delay_21(end)-1)*1e9,rad2deg(angle(h21)))
xlabel('Time [ns]')
ylabel('h(t), phase (deg)')

info_frame_td_channel = [my_convolution(info_frame_td, h11) my_convolution(info_frame_td, h21)];
pilots_frame_td_channel = [my_convolution(pilots_frame_td, h11) my_convolution(pilots_frame_td, h21)];

fprintf('Power_Channel = %f\n', signal_power(info_frame_td_channel(:,1))+signal_power(info_frame_td_channel(:,2)));

%% Add the AWGN (block "AWGN")
info_frame_td_noise = [awgn(complex(info_frame_td_channel(:,1)), SNR_dB, 'measured') awgn(complex(info_frame_td_channel(:,2)), SNR_dB, 'measured')];
pilots_frame_td_noise = [awgn(complex(pilots_frame_td_channel(:,1)), SNR_dB, 'measured') awgn(complex(pilots_frame_td_channel(:,2)), SNR_dB, 'measured')];

fprintf('Power_Rx = %f\n', signal_power(info_frame_td_noise(:,1)) + signal_power(info_frame_td_noise(:,2)));

%% Removing cyclic prefix and Converting to Frequency domain (blocks "FFT" and "Remove Cyclic prefix")
info_frame_fd = [fft(remove_cyclic_prefix(info_frame_td_noise(:,1), cp_length))./fr_len fft(remove_cyclic_prefix(info_frame_td_noise(:,2), cp_length))./fr_len];
pilots_frame_fd = [fft(remove_cyclic_prefix(pilots_frame_td_noise(:,1), cp_length))./fr_len fft(remove_cyclic_prefix(pilots_frame_td_noise(:,2), cp_length))./fr_len];

figure
plot(real(info_frame_fd), imag(info_frame_fd), "*", 'DisplayName','information frame', 'Color', 'black')
hold on
plot(real(pilots_frame_fd), imag(pilots_frame_fd), "*", 'DisplayName','pilots frame', 'Color', 'green')
legend()
xlabel('I')
ylabel('Q')
title("Before equalizer")

%% Equalizer training and using
info_frame_equalized_ZF = use_ZF_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands);
info_frame_equalized_MMSE = use_MMSE_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands, SNR_dB, 0);

figure
hold on
plot(real(info_frame_equalized_ZF), imag(info_frame_equalized_ZF), "*", 'DisplayName','Zero-Forcing')
plot(real(info_frame_equalized_MMSE), imag(info_frame_equalized_MMSE), "*", 'DisplayName','MMSE')
title("After equalizer")
legend()
xlabel('I')
ylabel('Q')

%% Decoded message from frame in frequency domain (block "Demodulator")
decoded_message_ZF = decode_frame(info_frame_equalized_ZF, M); % decoding frame
decoded_message_MMSE = decode_frame(info_frame_equalized_MMSE, M);

%% Metrics calculation (blocks "BER" and "EVM")
ber_ZF = evaluate_ber(message, decoded_message_ZF, M);
ber_MMSE = evaluate_ber(message, decoded_message_MMSE, M);
evm_ZF = evaluate_evm(info_frame_equalized_ZF, info_frame, guard_bands);
evm_MMSE = evaluate_evm(info_frame_equalized_MMSE, info_frame, guard_bands);

fileID = fopen('metrics.txt','w');
fprintf(fileID,'%s\t%s\t%s\t%s\n', "BER_ZF", "BER_MMSE", "EVM_ZF", "EVM_MMSE");
fprintf(fileID,'%f\t%f\t%f\t%f\n', ber_ZF, ber_MMSE, evm_ZF, evm_MMSE);
fclose(fileID);


