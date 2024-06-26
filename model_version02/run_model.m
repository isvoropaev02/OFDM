function [ber_ZF, evm_ZF, ber_MMSE, evm_MMSE] = run_model(M, fr_len, SNR_dB, channel_h, cp_length, guard_bands)
% runs model with given parameters
% Inputs:       M           : Modulator order
%               fr_len      : Length of the frame
%               SNR_db      : SNR in dB on the reciever
%               channel_h   : IR of channel
%               cp_length   : Length of the cyclic prefix
%               guard_bands : Guard band in spectrum

% Output:       ber and evm for 2 different equalizers

%% message to transmit and recieve (block "Bits stream")
message = randi([0 M-1], fr_len-length(guard_bands), 1); % decimal information symbols

%% Frame in frequency domain (blocks "Modulator" and "Pilot signals")
pilots_frame = generate_pilots_frame(fr_len, guard_bands);
info_frame = generate_information_frame(message, M, guard_bands); % creating frame

%% Converting to Time domain and adding cyclic prefix (blocks "IFFT" and "Cyclic prefix")
info_frame_td = add_cyclic_prefix(ifft(info_frame).*fr_len, cp_length);
pilots_frame_td = add_cyclic_prefix(ifft(pilots_frame).*fr_len, cp_length);

%% Channel
info_frame_td_channel = my_convolution(info_frame_td, channel_h);
pilots_frame_td_channel = my_convolution(pilots_frame_td, channel_h);

%% Add the AWGN (block "AWGN")
info_frame_td_noise = awgn(complex(info_frame_td_channel), SNR_dB, 'measured');
pilots_frame_td_noise = awgn(complex(pilots_frame_td_channel), SNR_dB, 'measured');

%% Removing cyclic prefix and Converting to Frequency domain (blocks "FFT" and "Remove Cyclic prefix")
info_frame_fd = fft(remove_cyclic_prefix(info_frame_td_noise, cp_length))./fr_len;
pilots_frame_fd = fft(remove_cyclic_prefix(pilots_frame_td_noise, cp_length))./fr_len;

%% Equalizer training and using
info_frame_equalized_ZF = use_ZF_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands);
info_frame_equalized_MMSE = use_MMSE_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands, SNR_dB, 0);

%% Decoded message from frame in frequency domain (block "Demodulator")
decoded_message_ZF = decode_frame(info_frame_equalized_ZF, M); % decoding frame
decoded_message_MMSE = decode_frame(info_frame_equalized_MMSE, M);

ber_ZF = evaluate_ber(message, decoded_message_ZF, M);
ber_MMSE = evaluate_ber(message, decoded_message_MMSE, M);
evm_ZF = evaluate_evm(info_frame_equalized_ZF, info_frame, guard_bands);
evm_MMSE = evaluate_evm(info_frame_equalized_MMSE, info_frame, guard_bands);

end

% 06.05.2024.
% created from main.m

