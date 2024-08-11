function [ber_ZF, evm_ZF, ber_MMSE, evm_MMSE] = run_MIMO_model(M, fr_len, SNR_dB, path_delay, path_gain_db, cp_length, guard_bands)
% runs MIMO (2x2) model with given parameters
% Inputs:       M                   : Modulator order
%               fr_len              : Length of the frame
%               SNR_db              : SNR in dB on the reciever
%               path_delay          : path delay of channels between antennas
%               path_gain_dB        : path loss of channels between antennas
%               cp_length           : Length of the cyclic prefix
%               guard_bands         : Guard band in spectrum

% Output:       ber and evm for 2 different equalizers

Nr = 2; % number of recieve antennas
Nt = 2; % number of transmitt antennas

[info_frame_td,message,info_frame] = MIMO_generate_output_info_signal(Nt, M, fr_len, cp_length, guard_bands);
[pilots_frame_td, pilots_frame] = MIMO_generate_output_pilot_signal(Nt, fr_len, cp_length, guard_bands);

h_full = MIMO_Rayleigh_channel(path_delay, path_gain_db, Nr, Nt);
info_frame_td_channel = MIMO_convolution(info_frame_td,h_full);
pilots_frame_td_channel = zeros(size(pilots_frame_td,1),size(h_full,2),size(pilots_frame_td,3));
for id_t = 1:Nt
    pilots_frame_td_channel(:,:,id_t) = MIMO_convolution(pilots_frame_td(:,:,id_t),h_full);
end

info_frame_td_noise = MIMO_AWGN(info_frame_td_channel, SNR_dB, Nr);
pilots_frame_td_noise = zeros(size(pilots_frame_td_channel));
for id_t = 1:Nt
    pilots_frame_td_noise(:,:,id_t) = MIMO_AWGN(pilots_frame_td_channel(:,:,id_t), SNR_dB, Nr);
end

info_frame_fd = MIMO_Rx_signal_to_fd(info_frame_td_noise, fr_len, cp_length, guard_bands);
pilots_frame_fd = zeros(fr_len-length(guard_bands), size(pilots_frame_td_channel,2), size(pilots_frame_td_channel,3));
for id_t = 1:Nt
    pilots_frame_fd(:,:,id_t) = MIMO_Rx_signal_to_fd(pilots_frame_td_noise(:,:,id_t), fr_len, cp_length, guard_bands);
end

info_frame_equalized_ZF = use_ZF_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands);
info_frame_equalized_MMSE = use_MMSE_equalizer(info_frame_fd, pilots_frame, pilots_frame_fd, guard_bands,SNR_dB, 0);

decoded_message_ZF = MIMO_decode_frame(info_frame_equalized_ZF, M); % decoding frame
decoded_message_MMSE = MIMO_decode_frame(info_frame_equalized_MMSE, M);

[ber_ZF, evm_ZF] = MIMO_metrics(message, decoded_message_ZF, M, info_frame_equalized_ZF, info_frame, guard_bands);
[ber_MMSE, evm_MMSE] = MIMO_metrics(message, decoded_message_MMSE, M, info_frame_equalized_MMSE, info_frame, guard_bands);


end

%30.06.2024. created