function [ber_ZF, evm_ZF, ber_MMSE, evm_MMSE] = run_SIMO_model(M, fr_len, SNR_dB, path_delay_11, path_gain_db_11, path_delay_21, path_gain_db_21, cp_length, guard_bands)
% runs SIMO (1x2) model with given parameters
% Inputs:       M                   : Modulator order
%               fr_len              : Length of the frame
%               SNR_db              : SNR in dB on the reciever
%               path_delay(11/22)   : path delay of channels to 2 antennas
%               path_gain(11/22)    : path loss of channels to 2 antennas
%               cp_length           : Length of the cyclic prefix
%               guard_bands         : Guard band in spectrum

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
h11 = Rayleigh_channel(path_delay_11, path_gain_db_11);
h21 = Rayleigh_channel(path_delay_21, path_gain_db_21);
info_frame_td_channel = [my_convolution(info_frame_td, h11) my_convolution(info_frame_td, h21)];
pilots_frame_td_channel = [my_convolution(pilots_frame_td, h11) my_convolution(pilots_frame_td, h21)];
%% Add the AWGN (block "AWGN")
info_frame_td_noise = [awgn(complex(info_frame_td_channel(:,1)), SNR_dB, 'measured') awgn(complex(info_frame_td_channel(:,2)), SNR_dB, 'measured')];
pilots_frame_td_noise = [awgn(complex(pilots_frame_td_channel(:,1)), SNR_dB, 'measured') awgn(complex(pilots_frame_td_channel(:,2)), SNR_dB, 'measured')];
%% Removing cyclic prefix and Converting to Frequency domain (blocks "FFT" and "Remove Cyclic prefix")
info_frame_fd = [fft(remove_cyclic_prefix(info_frame_td_noise(:,1), cp_length))./fr_len fft(remove_cyclic_prefix(info_frame_td_noise(:,2), cp_length))./fr_len];
pilots_frame_fd = [fft(remove_cyclic_prefix(pilots_frame_td_noise(:,1), cp_length))./fr_len fft(remove_cyclic_prefix(pilots_frame_td_noise(:,2), cp_length))./fr_len];
%% Equalizer training and using
info_frame_equalized_ZF = use_ZF_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands);
info_frame_equalized_MMSE = use_MMSE_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands, SNR_dB, 0);
%% Decoded message from frame in frequency domain (block "Demodulator")
decoded_message_ZF = decode_frame(info_frame_equalized_ZF, M); % decoding frame
decoded_message_MMSE = decode_frame(info_frame_equalized_MMSE, M);
%% Metrics calculation (blocks "BER" and "EVM")
ber_ZF = evaluate_ber(message, decoded_message_ZF, M);
ber_MMSE = evaluate_ber(message, decoded_message_MMSE, M);
evm_ZF = evaluate_evm(info_frame_equalized_ZF, info_frame, guard_bands);
evm_MMSE = evaluate_evm(info_frame_equalized_MMSE, info_frame, guard_bands);

end