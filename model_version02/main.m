% main performance file
% result of each block is written into .txt file

% 18.05.2024
% time and frequency values are specified

clear all; close all; clc
%pkg load communications

%% parameters
rng(2); % random seed setter (for repeating the same results)

M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
SNR_dB = 1; % [dBW] the signal power is normalized to 1 W
path_delay = [1 4 15 20]; % array of signal arriving delays
path_gain_db = [-5 0 -10 -15]; % average level of arriving signals in dB

% values from IEEE 802.11a for 20 MHz band
Bw = 20*10^6; % Hz -- Bandwidth
Ts = 3.2*10^(-6); % sec -- duration of the frame (3.2 us)
delta_f = 1/Ts; % Hz -- band between neighbouring subcarriers (312.5 kHz)
fr_len = 64; % the length of OFDM frame
cp_length = max([fr_len/2 path_delay(end)]); % the size of cyclic prefix (1.6 us)
guard_bands = [1 29 30 31 32 33 34 35 36];% guard band {-32 -31 -30 -29 0 28 29 30 31} subcarriers
% frequeny_range = linspace(-Bw/2, Bw/2, fr_len);
% time_range = linspace(0, 3*Ts/2, 3*fr_len/2);

%% message to transmit and recieve (block "Bits stream")
message = randi([0 M-1], fr_len-length(guard_bands), 1); % decimal information symbols
%dlmwrite('message.txt', dec2bin(message, log2(M)), 'Delimiter', '\n'); % but saving bits

%% Frame in frequency domain (blocks "Modulator" and "Pilot signals")
pilots_frame = generate_pilots_frame(fr_len, guard_bands);
info_frame = generate_information_frame(message, M, guard_bands); % creating frame
% writematrix([real(info_frame), imag(info_frame)], "info_frame.txt", "Delimiter", ",");
% writematrix([real(pilots_frame), imag(pilots_frame)], "pilots_frame.txt", "Delimiter", ",");

figure
hold on
title('Before IDFT')
plot(linspace(-Bw/2, Bw/2-delta_f, fr_len)*10^(-6), fftshift(abs(info_frame)))
xlabel('Frequency, MHz')
ylabel('Power spectrum of output signal')

%% Converting to Time domain and adding cyclic prefix (blocks "IFFT" and "Cyclic prefix")
info_frame_td = add_cyclic_prefix(ifft(info_frame).*fr_len, cp_length);
pilots_frame_td = add_cyclic_prefix(ifft(pilots_frame).*fr_len, cp_length);
% writematrix([real(info_frame_td), imag(info_frame_td)], "info_frame_td.txt", "Delimiter", ",");
% writematrix([real(pilots_frame_td), imag(pilots_frame_td)], "pilots_frame_td.txt", "Delimiter", ",");

fprintf('Power_Tx = %f\n', signal_power(info_frame_td));

figure
hold on
title('Spectrum in Tx output')
plot(linspace(-Bw/2, Bw/2-delta_f, 1024)*10^(-6), fftshift(abs(fft(ifft(info_frame), 1024))))
xlabel('Frequency, MHz')
ylabel('Power spectrum of output signal')


figure
hold on
title('Spectrum in Tx output with prefix')
plot(linspace(-Bw/2, Bw/2-delta_f, 1024)*10^(-6), fftshift(abs(fft(info_frame_td/96, 1024))))
xlabel('Frequency, MHz')
ylabel('Power spectrum of output signal')

%% Channel
h = Rayleigh_channel(path_delay, path_gain_db);
% writematrix([real(h), imag(h)], "h.txt", "Delimiter", ",");
% plot IR
figure
hold on
title('Impulse response of the channel')
subplot(211)
stem(abs(h))
xlabel('Time')
ylabel('h(t), abs')
subplot(212)
stem(rad2deg(angle(h)))
xlabel('Time')
ylabel('h(t), phase (deg)')

info_frame_td_channel = my_convolution(info_frame_td, h);
pilots_frame_td_channel = my_convolution(pilots_frame_td, h);
% writematrix([real(info_frame_td_channel), imag(info_frame_td_channel)], "info_frame_td_channel.txt", "Delimiter", ",");
% writematrix([real(pilots_frame_td_channel), imag(pilots_frame_td_channel)], "pilots_frame_td_channel.txt", "Delimiter", ",");

fprintf('Power_Channel = %f\n', signal_power(info_frame_td_channel));

%% Add the AWGN (block "AWGN")
info_frame_td_noise = awgn(complex(info_frame_td_channel), SNR_dB, 'measured');
pilots_frame_td_noise = awgn(complex(pilots_frame_td_channel), SNR_dB, 'measured');
% writematrix([real(info_frame_td_noise), imag(info_frame_td_noise)], "info_frame_td_noise.txt", "Delimiter", ",");
% writematrix([real(pilots_frame_td_noise), imag(pilots_frame_td_noise)], "pilots_frame_td_noise.txt", "Delimiter", ",");

fprintf('Power_Rx = %f\n', signal_power(info_frame_td_noise));

%% Removing cyclic prefix and Converting to Frequency domain (blocks "FFT" and "Remove Cyclic prefix")
info_frame_fd = fft(remove_cyclic_prefix(info_frame_td_noise, cp_length))./fr_len;
pilots_frame_fd = fft(remove_cyclic_prefix(pilots_frame_td_noise, cp_length))./fr_len;
% writematrix([real(info_frame_fd), imag(info_frame_fd)], "info_frame_fd.txt", "Delimiter", ",");
% writematrix([real(pilots_frame_fd), imag(pilots_frame_fd)], "pilots_frame_fd.txt", "Delimiter", ",");

figure
hold on
plot(real(info_frame_fd), imag(info_frame_fd), "*", 'DisplayName','information frame')
plot(real(pilots_frame_fd), imag(pilots_frame_fd), "*", 'DisplayName','pilots frame')
title("Before equalizer")
xlabel('I')
ylabel('Q')

%% Equalizer training and using
info_frame_equalized_ZF = use_ZF_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands);
info_frame_equalized_MMSE = use_MMSE_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands, SNR_dB, 0);
% writematrix([real(info_frame_equalized_ZF), imag(info_frame_equalized_ZF)], "info_frame_equalized_ZF.txt", "Delimiter", ",");
% writematrix([real(info_frame_equalized_MMSE), imag(info_frame_equalized_MMSE)], "info_frame_equalized_MMSE.txt", "Delimiter", ",");
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
% dlmwrite('message_ZF.txt',dec2bin(decoded_message_ZF, log2(M)),'Delimiter','\n');
% dlmwrite('message_MMSE.txt',dec2bin(decoded_message_MMSE, log2(M)),'Delimiter','\n');

%% Metrics calculation (blocks "BER" and "EVM")
ber_ZF = evaluate_ber(message, decoded_message_ZF, M);
ber_MMSE = evaluate_ber(message, decoded_message_MMSE, M);
evm_ZF = evaluate_evm(info_frame_equalized_ZF, info_frame, guard_bands);
evm_MMSE = evaluate_evm(info_frame_equalized_MMSE, info_frame, guard_bands);

fileID = fopen('metrics.txt','w');
fprintf(fileID,'%s\t%s\t%s\t%s\n', "BER_ZF", "BER_MMSE", "EVM_ZF", "EVM_MMSE");
fprintf(fileID,'%f\t%f\t%f\t%f\n', ber_ZF, ber_MMSE, evm_ZF, evm_MMSE);
fclose(fileID);


