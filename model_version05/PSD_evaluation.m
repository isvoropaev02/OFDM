clear all; close all;
% estimation of PSD of single transmitter output OFDM signal
% 06.06.2024.

num_of_frames = 20; % must be even --> 50 pilot frames with 50 info frames
M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM

% spectral parameters
channel_bw = 5*1e6; % Hz
scs = 15*1e3; % Hz - subcarrier spacing

% values from 3GPP TS 38.104
[fr_len, n_ifft, delta_t, cp_len, guard_bands] = get_params_from_nr_configuration(channel_bw, scs);


%% forming output signal
full_signal = zeros([n_ifft+cp_len,num_of_frames*2]);
for k=1:2:num_of_frames
    message = randi([0 M-1], fr_len-length(guard_bands), 1); % decimal information symbols
    info_frame = generate_information_frame(message, M, guard_bands); % creating frame
    pilots_frame = generate_pilots_frame(fr_len, guard_bands);
    info_frame_td = add_cyclic_prefix(ifft(info_frame, n_ifft).*fr_len, cp_len);
    pilots_frame_td = add_cyclic_prefix(ifft(pilots_frame, n_ifft).*fr_len, cp_len);
    full_signal(:,k) = pilots_frame_td;
    full_signal(:,k+1) = info_frame_td;
end

full_signal = reshape(full_signal, [], 1);
L = length(full_signal);

%% Using pwelch to estimate PSD
[psd, freq] = pwelch(full_signal,hamming(floor(L/256)),floor(L/512),2048, 1/delta_t); % Hamming window, two-sided psd estimate, 50% overlap 
%[psd, freq] = pwelch(full_signal);
figure(1)
plot((freq-freq(end)/2)*1e-6,fftshift(10*log10(psd)))
xlabel('Frequency [MHz]')
ylabel('PSD [dB]')
title('Welch’s power spectral density estimate')

%% plot hamming window
% Hs = hamming(64,'symmetric');
% Hp = hamming(63,'periodic');
% wvt = wvtool(Hs,Hp);
% legend(wvt.CurrentAxes,'Symmetric','Periodic')



