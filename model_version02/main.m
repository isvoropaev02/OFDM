% main performance file
% result of each block is written into .txt file

% 14.04.2024
% added random seed

clear all; close all; clc
%pkg load communications

%% parameters
rng(2); % random seed setter (for repeating the same results)

M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
fr_len = 64; % the length of OFDM frame
SNR_dB = 20; % [dBW] the signal power is normalized to 1 W
path_delay = [1 4 15 20]; % array of signal arriving delays
path_gain_db = [0 -10 -15 -40]; % average level of arriving signals in dB
cp_length = max([fr_len/2 path_delay(end)]); % the size of cyclic prefix
guard_bands = [];% пока не делаем [1 2 fr_len-1 fr_len]; % guard band in spectrum

%% message to transmit and recieve (block "Bits stream")
message = randi([0 M-1], fr_len-length(guard_bands), 1); % decimal information symbols
%dlmwrite('message.txt', dec2bin(message, log2(M)), 'Delimiter', '\n'); % but saving bits

%% Frame in frequency domain (blocks "Modulator" and "Pilot signals")
pilots_frame = generate_pilots_frame(fr_len, guard_bands);
info_frame = generate_information_frame(message, M, guard_bands); % creating frame
% writematrix([real(info_frame), imag(info_frame)], "info_frame.txt", "Delimiter", ",");
% writematrix([real(pilots_frame), imag(pilots_frame)], "pilots_frame.txt", "Delimiter", ",");

% figure
% title('Output spectrum')
% plot(abs(info_frame))

%% Converting to Time domain and adding cyclic prefix (blocks "IFFT" and "Cyclic prefix")
info_frame_td = add_cyclic_prefix(ifft(info_frame).*fr_len, cp_length);
pilots_frame_td = add_cyclic_prefix(ifft(pilots_frame).*fr_len, cp_length);
% writematrix([real(info_frame_td), imag(info_frame_td)], "info_frame_td.txt", "Delimiter", ",");
% writematrix([real(pilots_frame_td), imag(pilots_frame_td)], "pilots_frame_td.txt", "Delimiter", ",");

fprintf('Energy_Tx = %f\n', signal_energy(info_frame_td));

% figure
% title('Before channel')
% hold on
% plot(real(info_frame_td))
% plot(imag(info_frame_td))

%% Channel
h = Rayleigh_channel(path_delay, path_gain_db);
% writematrix([real(h), imag(h)], "h.txt", "Delimiter", ",");
% plot IR
figure
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

fprintf('Energy_Channel = %f\n', signal_energy(info_frame_td_channel));

%% Add the AWGN (block "AWGN")
info_frame_td_noise = awgn(complex(info_frame_td_channel), SNR_dB, 'measured');
pilots_frame_td_noise = awgn(complex(pilots_frame_td_channel), SNR_dB, 'measured');
% writematrix([real(info_frame_td_noise), imag(info_frame_td_noise)], "info_frame_td_noise.txt", "Delimiter", ",");
% writematrix([real(pilots_frame_td_noise), imag(pilots_frame_td_noise)], "pilots_frame_td_noise.txt", "Delimiter", ",");

fprintf('Energy_Rx = %f\n', signal_energy(info_frame_td_noise));

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
evm_ZF = evaluate_evm(info_frame_equalized_ZF, info_frame);
evm_MMSE = evaluate_evm(info_frame_equalized_MMSE, info_frame);

fileID = fopen('metrics.txt','w');
fprintf(fileID,'%s\t%s\t%s\t%s\n', "BER_ZF", "BER_MMSE", "EVM_ZF", "EVM_MMSE");
fprintf(fileID,'%f\t%f\t%f\t%f\n', ber_ZF, ber_MMSE, evm_ZF, evm_MMSE);
fclose(fileID);


