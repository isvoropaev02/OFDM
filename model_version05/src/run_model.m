function [ber_ZF, evm_ZF, ber_MMSE, evm_MMSE] = run_model(config)
% runs  model with given configuration parameters
% Inputs:       config              : configuration structure with
% properties:
%               *modulator_order
%               *SNR_dB
%               *Nr
%               *Nt
%               *TDL_channel
%               *fr_len
%               *delta_t
%               *n_ifft
%               *cp_len
%               *guard_bands

% Output:       ber and evm for 2 different equalizers

%% delay profile obtaining
path_delay = cell(1,config.Nr);
path_gain_db = cell(1,config.Nr);
for ii=1:config.Nr
    [path_delay{1,ii},path_gain_db{1,ii}] = ...
    nr_TDL_channel(config.TDL_channel, 60*ii*1e-9, 1/config.delta_t);
end

%% MIMO output signal
[info_frame_td,message,info_frame] =...
    MIMO_generate_output_info_signal(config.Nt, config.modulator_order, ...
    config.fr_len, config.n_ifft, config.cp_len, config.guard_bands);
[pilots_frame_td, pilots_frame] =...
    MIMO_generate_output_pilot_signal(config.Nt, config.fr_len, ...
    config.n_ifft, config.cp_len, config.guard_bands);

%% Rayleigh channel
h_full = MIMO_Rayleigh_channel(path_delay, path_gain_db, config.Nr, config.Nt);

info_frame_td_channel = MIMO_convolution(info_frame_td,h_full);
pilots_frame_td_channel =...
    zeros(size(pilots_frame_td,1),size(h_full,2),size(pilots_frame_td,3));
for id_t = 1:config.Nt
    pilots_frame_td_channel(:,:,id_t) =...
        MIMO_convolution(pilots_frame_td(:,:,id_t),h_full);
end

%% AWGN
info_frame_td_noise = MIMO_AWGN(info_frame_td_channel, config.SNR_dB, config.Nr);
pilots_frame_td_noise = zeros(size(pilots_frame_td_channel));
for id_t = 1:config.Nt
    pilots_frame_td_noise(:,:,id_t) = ...
    MIMO_AWGN(pilots_frame_td_channel(:,:,id_t), config.SNR_dB, config.Nr);
end

%% Rx signal
info_frame_fd = MIMO_Rx_signal_to_fd(info_frame_td_noise, config.fr_len,...
    config.cp_len, config.guard_bands);
pilots_frame_fd = zeros(config.fr_len-length(config.guard_bands),...
    size(pilots_frame_td_noise,2), size(pilots_frame_td_noise,3));
for id_t = 1:config.Nt
    pilots_frame_fd(:,:,id_t) = MIMO_Rx_signal_to_fd(pilots_frame_td_noise(:,:,id_t),...
        config.fr_len, config.cp_len, config.guard_bands);
end

info_frame_equalized_ZF = use_ZF_equalizer(info_frame_fd, pilots_frame,...
    pilots_frame_fd, config.guard_bands);
info_frame_equalized_MMSE = use_MMSE_equalizer(info_frame_fd, pilots_frame,...
    pilots_frame_fd, config.guard_bands,config.SNR_dB, 0);

%% Decoded message from frame in frequency domain (block "Demodulator")
decoded_message_ZF = MIMO_decode_frame(info_frame_equalized_ZF, config.modulator_order); % decoding frame
decoded_message_MMSE = MIMO_decode_frame(info_frame_equalized_MMSE, config.modulator_order);

%% output metrics
[ber_ZF, evm_ZF] = MIMO_metrics(message, decoded_message_ZF, config.modulator_order,...
    info_frame_equalized_ZF, info_frame, config.guard_bands);
[ber_MMSE, evm_MMSE] = MIMO_metrics(message, decoded_message_MMSE, config.modulator_order,...
    info_frame_equalized_MMSE, info_frame, config.guard_bands);
end